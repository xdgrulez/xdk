// Copyright 2002 by Denys Duchier Universitaet des Saarlandes
//
#include "mozart_cpi.hh"

//====================================================================
// NonMonIsIn(i,s,a)
//     binds a to 'in', 'out', or 'unknown' according to whether it is
// currently the case that i must be an element of s, or is known to
// lie outside the range of s, or this cannot be decided.
//
// This does not implement a _propagator_, but a function that returns
// an atom chracterizing the state of knowledge at the time of
// invocation.
//====================================================================

class NonMonIsIn : public OZ_Propagator {
private:
  static OZ_PropagatorProfile profile;
  OZ_Term _i;
  OZ_Term _s;
  OZ_Term _a;
public:
  NonMonIsIn(OZ_Term i,OZ_Term s,OZ_Term a)
    : _i(i),_s(s),_a(a) {}
  virtual OZ_Return propagate(void);
  virtual size_t sizeOf() { return sizeof(NonMonIsIn); }
  virtual OZ_PropagatorProfile *getProfile(void) const { return &profile; }
  virtual OZ_Term getParameters(void) const;
  virtual void sClone(void);
  virtual void gCollect(void);
};

OZ_PropagatorProfile NonMonIsIn::profile = "NatUtils.nonMonIsIn";

OZ_Term NonMonIsIn::getParameters(void) const
{
  return OZ_cons(_i,OZ_cons(_s,OZ_cons(_a,OZ_nil())));
}

void NonMonIsIn::sClone(void)
{
  OZ_sCloneTerm(_i);
  OZ_sCloneTerm(_s);
  OZ_sCloneTerm(_a);
}

void NonMonIsIn::gCollect(void)
{
  OZ_gCollectTerm(_i);
  OZ_gCollectTerm(_s);
  OZ_gCollectTerm(_a);
}

class NatUtilsExpect : public OZ_Expect {
public:
  OZ_expect_t expectFD(OZ_Term t) {
    return expectIntVar(t,fd_prop_any);
  }
  OZ_expect_t expectFS(OZ_Term t) {
    return expectFSetVar(t,fs_prop_bounds);
  }
};

#define OZ_EM_VAR "free variable"

OZ_BI_define(nu_nonmonisin,3,0)
{
  OZ_EXPECTED_TYPE(OZ_EM_FD","OZ_EM_FSET","OZ_EM_VAR);
  NatUtilsExpect pe;
  OZ_EXPECT(pe,0,expectFD);
  OZ_EXPECT(pe,1,expectFS);
  OZ_EXPECT(pe,2,expectVar);
  return pe.impose(new NonMonIsIn(OZ_in(0),OZ_in(1),OZ_in(2)));
}
OZ_BI_end

OZ_Return NonMonIsIn::propagate(void)
{
  static OZ_Term IN = OZ_atom("in");
  static OZ_Term OUT = OZ_atom("out");
  static OZ_Term UNKNOWN = OZ_atom("unknown");

  OZ_Term result = UNKNOWN;

  OZ_FDIntVar i;
  OZ_FSetVar  s;
  i.ask(_i);
  s.ask(_s);

  int k = i->getSingleElem();
  if (k >= 0) {
    // i is determined with value k
    if (s->isIn(k)) { result = IN; }
    else if (s->isNotIn(k)) { result = OUT; }
  } else {
    OZ_FSetValue is(*i);
    if (is <= s->getGlbSet()) { result = IN; }
    else if ((is & s->getLubSet()).getCard() == 0) { result = OUT; }
  }
  return (OZ_unify(_a,result) == PROCEED)?OZ_ENTAILED:OZ_FAILED;
}

//====================================================================
// SnapFS represents a snapshot of the state of a FS variable and
// allows to check whether this state has changed.
//====================================================================

class SnapFS {
private:
  int _known_in, _known_not_in, _card_size;
public:
  SnapFS() {};
  SnapFS(OZ_FSetVar&s) { *this = s; }
  SnapFS(OZ_FSetConstraint&sc) { *this = sc; }
  void operator = (OZ_FSetConstraint &sc)
  {
    _known_in = sc.getKnownIn();
    _known_not_in = sc.getKnownNotIn();
    _card_size = sc.getCardSize();
  }
  void operator = (OZ_FSetVar &s) { *this = *s; }
  bool operator == (OZ_FSetConstraint& sc) {
    return (_known_in == sc.getKnownIn()) &&
      (_known_not_in == sc.getKnownNotIn()) &&
      (_card_size == sc.getCardSize());
  }
  bool operator == (OZ_FSetVar& s) {
    return (*this == *s);
  }
  bool operator != (OZ_FSetConstraint& sc) {
    return ! (*this == sc);
  }
  bool operator != (OZ_FSetVar& s) {
    return ! (*this == s);
  }
};

class SnapFD {
private:
  int _size;
public:
  SnapFD() {};
  SnapFD(OZ_FDIntVar&i) { *this = i; }
  SnapFD(OZ_FiniteDomain&ic) { *this = ic; }
  void operator = (OZ_FiniteDomain& ic) { _size = ic.getSize(); }
  void operator = (OZ_FDIntVar& i) { *this = *i; }
  bool operator == (OZ_FiniteDomain& ic) { return _size==ic.getSize(); }
  bool operator == (OZ_FDIntVar& i) { return (*this == *i); }
  bool operator != (OZ_FiniteDomain& ic) { return ! (*this == ic); }
  bool operator != (OZ_FDIntVar& i) { return ! (*this == i); }
};

//====================================================================
// Filters implementing some useful constraints
//====================================================================

static inline
OZ_Return filter_fs_subset(OZ_FSetVar& s1,OZ_FSetVar& s2)
{
  if (! (*s1 <= *s2) || ! (*s2 >= *s1)) return OZ_FAILED;
  return (s1->getLubSet() <= s2->getGlbSet()) ? OZ_ENTAILED : OZ_SLEEP;
}

static inline
OZ_Return filter_fs_disjoint(OZ_FSetVar& s1,OZ_FSetVar& s2)
{
  SnapFS ss1;
  SnapFS ss2;
  do {
    ss1 = s1;
    ss2 = s2;
    if (! (*s1 != *s2) || ! (*s2 != *s1)) return OZ_FAILED;
  } while (ss1 != s1 || ss2 != s2);
  return ((s1->getLubSet() & s2->getLubSet()).getCard() == 0)
    ? OZ_ENTAILED : OZ_FAILED;
}

static inline int max(int x,int y) { return (x>y)?x:y; }
static inline int min(int x,int y) { return (x<y)?x:y; }

int FSetGetLowerBoundOfMax(OZ_FSetConstraint& c)
{
  int i = c.getCardMin();
  if (i==0) return c.getGlbMaxElem();
  int n = c.getLubMinElem();
  while (--i) n=c.getLubNextLargerElem(n);
  return max(n,c.getGlbMaxElem());
}

int FSetGetUpperBoundOfMin(OZ_FSetConstraint& c)
{
  int i = c.getCardMin();
  if (i==0) return c.getGlbMinElem();
  int n = c.getLubMaxElem();
  while (--i) n=c.getLubNextSmallerElem(n);
  int m = c.getGlbMinElem();
  return (m>=0)?min(n,m):n;
}

static inline
OZ_Return filter_fs_seq2(OZ_FSetVar& s1,OZ_FSetVar& s2)
{
  if (*s1 == fs_empty || *s2 == fs_empty) return OZ_ENTAILED;
  int lb_max = FSetGetLowerBoundOfMax(*s1);
  if (lb_max >= 0) {
    if (! s2->ge(lb_max+1)) return OZ_FAILED;
  }
  int ub_min = FSetGetUpperBoundOfMin(*s2);
  if (ub_min >= 0) {
    if (! s1->le(ub_min-1)) return OZ_FAILED;
  }
  return (s1->getLubMaxElem() < s2->getLubMinElem())
    ? OZ_ENTAILED : OZ_SLEEP;
}

static inline
OZ_Return filter_fd_int(OZ_FDIntVar&i,int lo,int hi)
{
  if (! (*i >= lo) || ! (*i <= hi)) return OZ_FAILED;
  return (lo <= i->getMinElem() && hi >= i->getMaxElem())
    ? OZ_ENTAILED : OZ_SLEEP;
}

static inline
OZ_Return filter_fd_int(OZ_FDIntVar&i,int k)
{
  return ((*i &= k)==0) ? OZ_FAILED : OZ_ENTAILED;
}

//====================================================================
//
//====================================================================

enum ClauseStatus {
  CLAUSE_SPECULATIVE,
  CLAUSE_ENTAILED,
  CLAUSE_REJECTED,
  CLAUSE_COMMITTED
};

class TreenessClause : public OZ_Propagator {
private:
  static OZ_PropagatorProfile profile;
  OZ_Term _s1;
  OZ_Term _s2;
  OZ_Term _c;
  ClauseStatus _status;
  int _name;
  bool _init;
public:
  TreenessClause(OZ_Term s1,OZ_Term s2,OZ_Term c,int n)
    : _s1(s1),_s2(s2),_c(c),_status(CLAUSE_SPECULATIVE),_name(n),_init(false) {}
  virtual OZ_Return propagate(void);
  virtual size_t sizeOf() { return sizeof(TreenessClause); }
  virtual OZ_PropagatorProfile * getProfile(void) const { return &profile; }
  virtual OZ_Term getParameters(void) const;
  virtual void sClone(void);
  virtual void gCollect(void);
  OZ_Return propagate1(void);
  OZ_Return propagate2(void);
  OZ_Return propagate3(void);
  OZ_Return propagate4(void);
  OZ_Return propagate12(void);
};

OZ_PropagatorProfile TreenessClause::profile = "NatUtils.treenessClause";

OZ_Term TreenessClause::getParameters(void) const
{
  return OZ_cons(_s1,OZ_cons(_s2,OZ_cons(_c,OZ_nil())));
}

void TreenessClause::sClone(void)
{
  OZ_sCloneTerm(_s1);
  OZ_sCloneTerm(_s2);
  OZ_sCloneTerm(_c);
}

void TreenessClause::gCollect(void)
{
  OZ_gCollectTerm(_s1);
  OZ_gCollectTerm(_s2);
  OZ_gCollectTerm(_c);
}

OZ_BI_define(nu_treenessclause,4,0)
{
  OZ_EXPECTED_TYPE(OZ_EM_FSET","OZ_EM_FSET","OZ_EM_FD","OZ_EM_INT);
  NatUtilsExpect pe;
  OZ_EXPECT(pe,0,expectFS);
  OZ_EXPECT(pe,1,expectFS);
  int dummy;
  OZ_EXPECT_SUSPEND(pe,2,expectFD,dummy);
  OZ_EXPECT(pe,3,expectInt);
  int name = OZ_intToC(OZ_in(3));
  if (name==1 || name==2 || name==3 || name==4 || name==12)
    return pe.impose(new TreenessClause(OZ_in(0),OZ_in(1),OZ_in(2),name));
  return OZ_FAILED;
}
OZ_BI_end

OZ_Return TreenessClause::propagate(void)
{
  if (!_init) {
    OZ_FDIntVar c(_c);
    if ((*c >= 1)==0 || (*c <= 4)==0) {
      c.fail();
      return OZ_FAILED;
    }
    c.leave();
    _init = true;
  }
  switch (_name) {
  case 1: return propagate1();
  case 2: return propagate2();
  case 3: return propagate3();
  case 4: return propagate4();
  case 12:return propagate12();
  }
  Assert(0);
  return OZ_FAILED;
}

OZ_Return TreenessClause::propagate1()
{
  switch (_status) {
  case CLAUSE_SPECULATIVE:
    {
      OZ_FDIntVar c;
      c.ask(_c);
      if (*c == 1) {
	_status = CLAUSE_COMMITTED;
	goto committed;
      } else if (*c != 1) {
	_status = CLAUSE_REJECTED;
	goto rejected;
      }
      OZ_FSetVar s1;
      OZ_FSetVar s2;
      s1.readEncap(_s1);
      s2.readEncap(_s2);
      SnapFS snap_s1 = s1;
      SnapFS snap_s2 = s2;
      OZ_Return r;
      if (!s1->putCard(1,fs_sup) || !s2->putCard(1,fs_sup)) goto failed;
      r = filter_fs_seq2(s1,s2);
      if (r==OZ_FAILED) {
      failed:
	s1.fail();
	s2.fail();
	_status = CLAUSE_REJECTED;
	c.read(_c);
	if ((*c -= 1)==0) {
	  c.fail();
	  return OZ_FAILED;
	} else {
	  c.leave();
	  goto rejected;
	}
      }
      if (r==OZ_ENTAILED && snap_s1==s1 && snap_s2==s2) {
	_status = CLAUSE_ENTAILED;
      } else {
	r = OZ_SLEEP;
      }
      s1.leave();
      s2.leave();
      return r;
    }
  case CLAUSE_ENTAILED:
    return OZ_ENTAILED;
  case CLAUSE_REJECTED:
  rejected:
    return OZ_ENTAILED;
  case CLAUSE_COMMITTED:
  committed:
    {
      OZ_FSetVar s1(_s1);
      OZ_FSetVar s2(_s2);
      OZ_Return r;
      if (!s1->putCard(1,fs_sup) || !s2->putCard(1,fs_sup)) goto fail2;
      r = filter_fs_seq2(s1,s2);
      if (r==OZ_FAILED) {
      fail2:
	s1.fail();
	s2.fail();
	return OZ_FAILED;
      }
      s1.leave();
      s2.leave();
      return r;
    }
  }
  Assert(0);
  return OZ_FAILED;
}

OZ_Return TreenessClause::propagate2()
{
  switch (_status) {
  case CLAUSE_SPECULATIVE:
    {
      OZ_FDIntVar c;
      c.ask(_c);
      if (*c == 2) {
	_status = CLAUSE_COMMITTED;
	goto committed;
      } else if (*c != 2) {
	_status = CLAUSE_REJECTED;
	goto rejected;
      }
      OZ_FSetVar s1;
      OZ_FSetVar s2;
      s1.readEncap(_s1);
      s2.readEncap(_s2);
      SnapFS snap_s1 = s1;
      SnapFS snap_s2 = s2;
      OZ_Return r;
      if (!s1->putCard(1,fs_sup) || !s2->putCard(1,fs_sup)) goto failed;
      r = filter_fs_seq2(s2,s1);
      if (r==OZ_FAILED) {
      failed:
	s1.fail();
	s2.fail();
	_status = CLAUSE_REJECTED;
	c.read(_c);
	if ((*c -= 1)==0) {
	  c.fail();
	  return OZ_FAILED;
	} else {
	  c.leave();
	  goto rejected;
	}
      }
      if (r==OZ_ENTAILED && snap_s1==s1 && snap_s2==s2) {
	_status = CLAUSE_ENTAILED;
      } else {
	r = OZ_SLEEP;
      }
      s1.leave();
      s2.leave();
      return r;
    }
  case CLAUSE_ENTAILED:
    return OZ_ENTAILED;
  case CLAUSE_REJECTED:
  rejected:
    return OZ_ENTAILED;
  case CLAUSE_COMMITTED:
  committed:
    {
      OZ_FSetVar s1(_s1);
      OZ_FSetVar s2(_s2);
      OZ_Return r;
      if (!s1->putCard(1,fs_sup) || !s2->putCard(1,fs_sup)) goto fail2;
      r = filter_fs_seq2(s2,s1);
      if (r==OZ_FAILED) {
      fail2:
	s1.fail();
	s2.fail();
	return OZ_FAILED;
      }
      s1.leave();
      s2.leave();
      return r;
    }
  }
  Assert(0);
  return OZ_FAILED;
}

OZ_Return TreenessClause::propagate3()
{
  switch (_status) {
  case CLAUSE_SPECULATIVE:
    {
      OZ_FDIntVar c;
      c.ask(_c);
      if (*c == 3) {
	_status = CLAUSE_COMMITTED;
	goto committed;
      } else if (*c != 3) {
	_status = CLAUSE_REJECTED;
	goto rejected;
      }
      OZ_FSetVar s1;
      OZ_FSetVar s2;
      s1.readEncap(_s1);
      s2.readEncap(_s2);
      SnapFS snap_s1 = s1;
      SnapFS snap_s2 = s2;
      OZ_Return r;
      r = filter_fs_subset(s1,s2);
      if (r==OZ_FAILED) {
	s1.fail();
	s2.fail();
	_status = CLAUSE_REJECTED;
	c.read(_c);
	if ((*c -= 3)==0) {
	  c.fail();
	  return OZ_FAILED;
	} else {
	  c.leave();
	  goto rejected;
	}
      }
      if (r==OZ_ENTAILED && snap_s1==s1 && snap_s2==s2) {
	_status = CLAUSE_ENTAILED;
      } else {
	r = OZ_SLEEP;
      }
      s1.leave();
      s2.leave();
      return r;
    }
  case CLAUSE_ENTAILED:
    return OZ_ENTAILED;
  case CLAUSE_REJECTED:
  rejected:
    return OZ_ENTAILED;
  case CLAUSE_COMMITTED:
  committed:
    {
      OZ_FSetVar s1(_s1);
      OZ_FSetVar s2(_s2);
      OZ_Return r;
      r = filter_fs_subset(s1,s2);
      if (r==OZ_FAILED) {
	s1.fail();
	s2.fail();
	return OZ_FAILED;
      }
      s1.leave();
      s2.leave();
      return r;
    }
  }
  Assert(0);
  return OZ_FAILED;
}

OZ_Return TreenessClause::propagate4()
{
  switch (_status) {
  case CLAUSE_SPECULATIVE:
    {
      OZ_FDIntVar c;
      c.ask(_c);
      if (*c == 4) {
	_status = CLAUSE_COMMITTED;
	goto committed;
      } else if (*c != 4) {
	_status = CLAUSE_REJECTED;
	goto rejected;
      }
      OZ_FSetVar s1;
      OZ_FSetVar s2;
      s1.readEncap(_s1);
      s2.readEncap(_s2);
      SnapFS snap_s1 = s1;
      SnapFS snap_s2 = s2;
      OZ_Return r;
      r = filter_fs_subset(s2,s1);
      if (r==OZ_FAILED) {
      failed:
	s1.fail();
	s2.fail();
	_status = CLAUSE_REJECTED;
	c.read(_c);
	if ((*c -= 4)==0) {
	  c.fail();
	  return OZ_FAILED;
	} else {
	  c.leave();
	  goto rejected;
	}
      }
      // check strict subset
      {
	int card_max1 = s1->getCardMax();
	if (card_max1==0) goto failed;
	if (!s2->putCard(0,card_max1-1)) goto failed;
	if (s2->getCardMax() >= s1->getCardMin()) r=OZ_SLEEP;
      }
      if (r==OZ_ENTAILED && snap_s1==s1 && snap_s2==s2) {
	_status = CLAUSE_ENTAILED;
      } else {
	r = OZ_SLEEP;
      }
      s1.leave();
      s2.leave();
      return r;
    }
  case CLAUSE_ENTAILED:
    return OZ_ENTAILED;
  case CLAUSE_REJECTED:
  rejected:
    return OZ_ENTAILED;
  case CLAUSE_COMMITTED:
  committed:
    {
      OZ_FSetVar s1(_s1);
      OZ_FSetVar s2(_s2);
      OZ_Return r;
      r = filter_fs_subset(s2,s1);
      if (r==OZ_FAILED) {
      fail2:
	s1.fail();
	s2.fail();
	return OZ_FAILED;
      }
      // check strict subset
      {
	int card_max1 = s1->getCardMax();
	if (card_max1==0) goto fail2;
	if (!s2->putCard(0,card_max1-1)) goto fail2;
	if (s2->getCardMax() >= s1->getCardMin()) r=OZ_SLEEP;
      }
      s1.leave();
      s2.leave();
      return r;
    }
  }
  Assert(0);
  return OZ_FAILED;
}

OZ_Return TreenessClause::propagate12()
{
  switch (_status) {
  case CLAUSE_SPECULATIVE:
    {
      OZ_FDIntVar c;
      c.ask(_c);
      if (!c->isIn(3) && !c->isIn(4)) {
	_status = CLAUSE_COMMITTED;
	goto committed;
      } else if (!c->isIn(1) && !c->isIn(2)) {
	_status = CLAUSE_REJECTED;
	goto rejected;
      }
      OZ_FSetVar s1;
      OZ_FSetVar s2;
      s1.readEncap(_s1);
      s2.readEncap(_s2);
      SnapFS snap_s1 = s1;
      SnapFS snap_s2 = s2;
      OZ_Return r;
      if (!s1->putCard(1,fs_sup) || !s2->putCard(1,fs_sup)) goto failed;
      r = filter_fs_disjoint(s1,s2);
      if (r==OZ_FAILED) {
      failed:
	s1.fail();
	s2.fail();
	_status = CLAUSE_REJECTED;
	c.read(_c);
	if ((*c -= 1)==0 || (*c -= 2)==0) {
	  c.fail();
	  return OZ_FAILED;
	} else {
	  c.leave();
	  goto rejected;
	}
      }
      if (r==OZ_ENTAILED && snap_s1==s1 && snap_s2==s2) {
	_status = CLAUSE_ENTAILED;
      } else {
	r = OZ_SLEEP;
      }
      s1.leave();
      s2.leave();
      return r;
    }
  case CLAUSE_ENTAILED:
    return OZ_ENTAILED;
  case CLAUSE_REJECTED:
  rejected:
    return OZ_ENTAILED;
  case CLAUSE_COMMITTED:
  committed:
    {
      OZ_FSetVar s1(_s1);
      OZ_FSetVar s2(_s2);
      OZ_Return r;
      if (!s1->putCard(1,fs_sup) || !s2->putCard(1,fs_sup)) goto fail2;
      r = filter_fs_disjoint(s1,s2);
      if (r==OZ_FAILED) {
      fail2:
	s1.fail();
	s2.fail();
	return OZ_FAILED;
      }
      s1.leave();
      s2.leave();
      return r;
    }
  }
  Assert(0);
  return OZ_FAILED;
}

OZ_C_proc_interface *oz_init_module(void)
{
  static OZ_C_proc_interface table[] = {
    {"nonMonIsIn",3,0,nu_nonmonisin},
    {"treenessClause",4,0,nu_treenessclause},
    {0,0,0,0}
  };
  return table;
}
char oz_module_name[] = "NatUtils";
