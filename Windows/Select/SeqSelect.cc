#include "mozart_cpi_extra.hh"

class SeqSelectPropagator : public OZ_Propagator {
private:
  static OZ_PropagatorProfile profile;
  OZ_Term * _tuple;
  OZ_Term   _index;
  int size;
  bool initialized;
public:
  SeqSelectPropagator(OZ_Term tuple,OZ_Term index)
    : _index(index), size(OZ_vectorSize(tuple)), initialized(false)
  {
    _tuple = OZ_hallocOzTerms(size);
    OZ_getOzTermVector(tuple,_tuple);
  }
  virtual OZ_Return propagate(void);
  virtual size_t sizeOf() { return sizeof(SeqSelectPropagator); }
  virtual OZ_PropagatorProfile * getProfile(void) const { return &profile; }
  virtual OZ_Term getParameters(void) const;
  virtual void sClone(void);
  virtual void gCollect(void);
};

OZ_PropagatorProfile SeqSelectPropagator::profile = "Select.seqselect";

OZ_Term SeqSelectPropagator::getParameters(void) const
{
  OZ_Term lst = OZ_nil();
  for (int i=size; i--;) {
    OZ_Term t = _tuple[i];
    if (t==0 || t==1) t=OZ_unit();
    lst=OZ_cons(t,lst);
  }
  return OZ_cons(lst,OZ_cons(_index,OZ_nil()));
}

void SeqSelectPropagator::sClone(void)
{
  _tuple = OZ_sCloneAllocBlock(size,_tuple);
  OZ_sCloneTerm(_index);
}
void SeqSelectPropagator::gCollect(void)
{
  _tuple = OZ_gCollectAllocBlock(size,_tuple);
  OZ_gCollectTerm(_index);
}

OZ_BI_define(set_seqselect,2,0)
{
  OZ_EXPECTED_TYPE(OZ_EM_VECT OZ_EM_FSET "," OZ_EM_FSET);
  SelectExpect pe;
  int dummy;
  OZ_EXPECT_SUSPEND(pe,0,expectFSVector,dummy);
  OZ_EXPECT_SUSPEND(pe,1,expectFS      ,dummy);
  return pe.impose(new SeqSelectPropagator(OZ_in(0),OZ_in(1)));
}
OZ_BI_end

//====================================================================
// copied from intsets.cc
//====================================================================

// for seq/propagation, we can do better than to propagate the
// known information: we can propagate necessary bounds even on
// the unknown stuff.  For example, if a set var has cardinality
// at least N and its LUB is {i1 i2 ... iN ...}, then its maximum
// element (when N>0) is at least iN, which means that the next
// set in the sequence must be above that limit.  Similarly in
// the other direction.  For this reason, we define the auxiliary
// functions FSetGetLowerBoundOfMax and FSetGetUpperBoundOfMin.

// Here we approximate the max element in a set.
// It must be at least as large as the largest element
// in the GLB.  However, if the cardinality is at least
// N, then it must be at least as large as the Nth smallest
// element in the LUB, which could be larger than the
// largest element currently in the GLB.
//
// Note: if the set _could_ be empty, then this _must_ return -1

static int
FSetGetLowerBoundOfMax(OZ_FSetConstraint& c)
{
  // just in case we _know_ that there are no elements
  if (c.getCardMax()<=0) return -1;
  // else: the set must contain at least i elements
  int i = c.getCardMin();
  // if i==0: we don't know anything about cardinality.
  // the set could be empty.  we expect GLB to still be
  // empty, but just in case it's not, we guess its
  // max element (-1 if empty).
  if (i==0) return c.getGlbMaxElem();
  // else, we start counting upwards from the min element
  // of LUB
  int n = c.getLubMinElem();
  while (--i) {
    n=c.getLubNextLargerElem(n);
    // in case we run out of elements (should not happen)
    if (n<0) break;
  }
  return max(n,c.getGlbMaxElem());
}

// Similarly for the min element

static int
FSetGetUpperBoundOfMin(OZ_FSetConstraint& c)
{
  // just in case there can be no elements
  if (c.getCardMax()<=0) return -1;
  // else the set must contain at least i elements
  int i = c.getCardMin();
  // if i==0: we know nothing about cardinality. the set
  // could be empty.  we expect GLB to still be empty,
  // but, just in case it's not, we guess its min element
  // (-1 if empty)
  if (i==0) return c.getGlbMinElem();
  // else we start counting downward from the max element
  // of LUB
  int n = c.getLubMaxElem();
  while (--i) {
    n=c.getLubNextSmallerElem(n);
    // in case we run out of elements (should not happen)
    if (n<0) break;
  }
  int m = c.getGlbMinElem();
  return (m<0)?n:((n<0)?m:min(n,m));
}

OZ_Return SeqSelectPropagator::propagate(void)
{

  OZ_FSetVar index(_index);
  OZ_FSetConstraint& zindex = *index;

  if (! initialized)
    {
      initialized = true;

      if (size==0)
	if (!(zindex <= fs_empty)) {
	  index.fail();
	  return OZ_FAILED;
	} else {
	  index.leave();
	  return OZ_ENTAILED;
	}

      if (zindex.le(size)==0 || zindex.ge(1)==0) {
	index.fail();
	return OZ_FAILED;
      }
    }


  OZ_FSetVar tuple[size];
  OZ_FSetVar_Iterator tuple_iter(size,tuple);
  tuple_iter.read(_tuple);

  // drop all elements that no longer correspond to indices
  // in the set of indices

  for (int i=size;i--;) {
    OZ_Term t = _tuple[i];
    if (t) {
      if (zindex.isNotIn(i+1)) {
	tuple[i].dropParameter();
	_tuple[i]=1;
      }
    }
  }

  {
    // lb_max_sofar is the largest element known to occur in the
    // selection to the left of the current set
    int lb_max_sofar = -1;

    for (int i=0;i<size;i++) {

      OZ_Term t = _tuple[i];

      // skip dropped params
      if (t==0 || t==1) continue;

      OZ_FSetConstraint& zcandidate = *tuple[i];

      // check if zcandidate is inconsistent with lb_max_sofar i.e. if
      // there must be some element in zcandidate that is =<
      // lb_max_sofar.

      int ub_min = FSetGetUpperBoundOfMin(zcandidate);

      if (lb_max_sofar>=0 && ub_min>=0 && ub_min<=lb_max_sofar)
	{
	  // drop that position
	  if (!(zindex -= i+1)) goto failed;
	  tuple[i].dropParameter();
	  _tuple[i]=1;
	}
      else if (zindex.isIn(i+1))
	// if position is known to be selected,
	{
	  // then it must be above the current lb_max_sofar
	  if (lb_max_sofar>=0)
	    if (!zcandidate.ge(lb_max_sofar+1)) goto failed;
	  // update lb_max_sofar
	  lb_max_sofar = max(lb_max_sofar,FSetGetLowerBoundOfMax(zcandidate));
	}
    }
  }

  {
    // ub_min_sofar is the smallest element known to occur in the
    // selection to the right of the current set
    int ub_min_sofar = -1;

    for (int i=size;i--;) {

      OZ_Term t = _tuple[i];

      // skip dropped params
      if (t==0 || t==1) continue;

      OZ_FSetConstraint& zcandidate = *tuple[i];

      // check if candidate is inconsistent with ub_min_sofar i.e. if
      // there must be some element in zcandidate that is >=
      // ub_min_sofar

      int lb_max = FSetGetLowerBoundOfMax(zcandidate);

      if (ub_min_sofar>=0 && lb_max>=0 && lb_max>=ub_min_sofar)
	{
	  // drop that position
	  if (!(zindex -= i+1)) goto failed;
	  tuple[i].dropParameter();
	  _tuple[i]=1;
	}
      else if (zindex.isIn(i+1))
	// if position is known to be selected
	{
	  // then it must be below the current ub_min_sofar
	  if (ub_min_sofar>=0)
	    {
	      // this can only make the upper bound of min of the
	      // candidate smaller - therefore it cannot affect
	      // the inferences made in the first loop (going upward)
	      if (!zcandidate.le(ub_min_sofar-1)) goto failed;
	    }
	  // update ub_min_sofar
	  int ub_min = FSetGetUpperBoundOfMin(zcandidate);
	  if (ub_min>=0)
	    ub_min_sofar = (ub_min_sofar<0) ? ub_min : min(ub_min_sofar,ub_min);
	}
    }
  }

  // check whether the constraint is entailed

  {
    bool entailed = true;
    int max_sofar = -1;
    for (int i=0;i<size;i++) {
      OZ_Term t = _tuple[i];
      if (t==0 || t==1) continue;
      // at this point we know that the set is a possibility
      OZ_FSetConstraint& zcandidate = *tuple[i];
      int my_max = zcandidate.getLubMaxElem();
      // if this set is empty, it does not affect the constraint
      if (my_max<0) continue;
      int my_min = zcandidate.getLubMinElem();
      // if the smallest possible element in the current set
      // is =< than the largest possible element to the left
      // then we cannot be sure that the sequentiality constraint
      // is satisfied
      if (my_min<=max_sofar) entailed=false;
      max_sofar=max(max_sofar,my_max);
    }
    tuple_iter.leave(_tuple);
    index.leave();
    return (entailed) ? OZ_ENTAILED : OZ_SLEEP;
  }

 failed:
  tuple_iter.fail(_tuple);
  index.fail();
  return OZ_FAILED;
}

OZ_BI_proto(set_seqselect);

OZ_C_proc_interface *oz_init_module(void)
{
  static OZ_C_proc_interface table[] = {
    {"seqselect",2,0,set_seqselect},
    {0,0,0,0},
  };
  return table;
}

char oz_module_name[] = "SeqSelect";
