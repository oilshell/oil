#ifndef MYCPP_GC_TUPLE_H
#define MYCPP_GC_TUPLE_H

#include <type_traits>

#include "mycpp/gc_obj.h"

template <class A, class B>
class Tuple2 {
  typedef Tuple2<A, B> this_type;

 public:
  Tuple2(A a, B b) : a_(a), b_(b) {
  }

  A at0() {
    return a_;
  }
  B at1() {
    return b_;
  }

  static constexpr ObjHeader obj_header() {
    return ObjHeader::Tuple(field_mask(), sizeof(this_type));
  }

  static constexpr uint32_t field_mask() {
    return (std::is_pointer<A>() ? maskbit(offsetof(this_type, a_)) : 0) |
           (std::is_pointer<B>() ? maskbit(offsetof(this_type, b_)) : 0);
  }

 private:
  A a_;
  B b_;
};

template <class A, class B, class C>
class Tuple3 {
  typedef Tuple3<A, B, C> this_type;

 public:
  Tuple3(A a, B b, C c) : a_(a), b_(b), c_(c) {
  }
  A at0() {
    return a_;
  }
  B at1() {
    return b_;
  }
  C at2() {
    return c_;
  }

  static constexpr ObjHeader obj_header() {
    return ObjHeader::Tuple(field_mask(), sizeof(this_type));
  }

  static constexpr uint32_t field_mask() {
    return (std::is_pointer<A>() ? maskbit(offsetof(this_type, a_)) : 0) |
           (std::is_pointer<B>() ? maskbit(offsetof(this_type, b_)) : 0) |
           (std::is_pointer<C>() ? maskbit(offsetof(this_type, c_)) : 0);
  }

 private:
  A a_;
  B b_;
  C c_;
};

template <class A, class B, class C, class D>
class Tuple4 {
  typedef Tuple4<A, B, C, D> this_type;

 public:
  Tuple4(A a, B b, C c, D d) : a_(a), b_(b), c_(c), d_(d) {
  }
  A at0() {
    return a_;
  }
  B at1() {
    return b_;
  }
  C at2() {
    return c_;
  }
  D at3() {
    return d_;
  }

  static constexpr ObjHeader obj_header() {
    return ObjHeader::Tuple(field_mask(), sizeof(this_type));
  }

  static constexpr uint32_t field_mask() {
    return (std::is_pointer<A>() ? maskbit(offsetof(this_type, a_)) : 0) |
           (std::is_pointer<B>() ? maskbit(offsetof(this_type, b_)) : 0) |
           (std::is_pointer<C>() ? maskbit(offsetof(this_type, c_)) : 0) |
           (std::is_pointer<D>() ? maskbit(offsetof(this_type, d_)) : 0);
  }

 private:
  A a_;
  B b_;
  C c_;
  D d_;
};

template <class A, class B, class C, class D, class E>
class Tuple5 {
  typedef Tuple5<A, B, C, D, E> this_type;

 public:
  Tuple5(A a, B b, C c, D d, E e) : a_(a), b_(b), c_(c), d_(d), e_(e) {
  }
  A at0() {
    return a_;
  }
  B at1() {
    return b_;
  }
  C at2() {
    return c_;
  }
  D at3() {
    return d_;
  }
  E at4() {
    return e_;
  }

  static constexpr ObjHeader obj_header() {
    return ObjHeader::Tuple(field_mask(), sizeof(this_type));
  }

  static constexpr uint32_t field_mask() {
    return (std::is_pointer<A>() ? maskbit(offsetof(this_type, a_)) : 0) |
           (std::is_pointer<B>() ? maskbit(offsetof(this_type, b_)) : 0) |
           (std::is_pointer<C>() ? maskbit(offsetof(this_type, c_)) : 0) |
           (std::is_pointer<D>() ? maskbit(offsetof(this_type, d_)) : 0) |
           (std::is_pointer<E>() ? maskbit(offsetof(this_type, e_)) : 0);
  }

 private:
  A a_;
  B b_;
  C c_;
  D d_;
  E e_;
};

#endif  // MYCPP_GC_TUPLE_H
