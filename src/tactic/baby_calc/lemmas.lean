/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin
-/

import algebra.group_with_zero
import ring_theory.witt_vector.basic
import analysis.special_functions.trigonometric
-- TODO: minimize these imports

/-! # Lemmas for the `baby_calc` tactic

In this file we record a long list of lemmas in a certain standard form.
We then add those lemmas to a lookup table.

Take as example
```
lemma left_mul_cancel' [cancel_monoid_with_zero α] {a b : α} (c : α)
  (h : c * a = c * b) (h0 : c ≠ 0) : a = b := (mul_right_inj' h0).mp h
```

We point out two things:

- the argument `c` is always explicit, even if it is determined by a later argument
- the side condition `h0` comes after the main hypothesis `h`

In this way, we can try to apply lemmas from a long list,
without worry about the position of arguments:
if there are side conditions, they come later in the list,
and will automatically create new goals

-/

namespace baby_calc

section standard_lemmas

variables {α : Type*}

/-! ## EQ -/

/-! ### mul -/

lemma left_mul_cancel [left_cancel_semigroup α] {a b : α} (c : α)
  (h : c * a = c * b) : a = b := (mul_right_inj c).mp h

lemma right_mul_cancel [right_cancel_semigroup α] {a b : α} (c : α)
  (h : a * c = b * c) : a = b := (mul_left_inj c).mp h

lemma left_mul_cancel' [cancel_monoid_with_zero α] {a b : α} (c : α)
  (h : c * a = c * b) (h0 : c ≠ 0) : a = b := (mul_right_inj' h0).mp h

lemma right_mul_cancel' [cancel_monoid_with_zero α] {a b : α} (c : α)
  (h : a * c = b * c) (h0 : c ≠ 0) : a = b := (mul_left_inj'  h0).mp h

/-! ### add -/

lemma left_add_cancel [add_left_cancel_semigroup α] {a b : α} (c : α)
  (h : c + a = c + b) : a = b := (add_right_inj c).mp h

lemma right_add_cancel [add_right_cancel_semigroup α] {a b : α} (c : α)
  (h : a + c = b + c) : a = b := (add_left_inj c).mp h

/-! ### div -/
lemma left_div_cancel [field α] {a b : α} (c : α)
  (h : c / a = c / b) (h0 : c ≠ 0) : a = b := inv_inj'.mp $ (mul_right_inj' h0).mp h
-- TODO: PR ↑ to mathlib

lemma right_div_cancel [group_with_zero α] {a b : α} (c : α)
  (h : a / c = b / c) (h0 : c ≠ 0) : a = b := (div_left_inj' h0).mp h

/-! ### sub -/

lemma left_sub_cancel [add_group α] {a b : α} (c : α)
  (h : c - a = c - b) : a = b := sub_right_inj.mp h

lemma right_sub_cancel [add_group α] {a b : α} (c : α)
  (h : a - c = b - c) : a = b := sub_left_inj.mp h

/-! ### inv -/
lemma inv_cancel [group α] {a b : α}
  (h : a⁻¹ = b⁻¹) : a = b := inv_inj.mp h

lemma inv_cancel' [group_with_zero α] {a b : α}
  (h : a⁻¹ = b⁻¹) : a = b := inv_inj'.mp h

/-! ### neg -/
lemma neg_cancel [add_group α] {a b : α}
  (h : -a = -b) : a = b := neg_inj.mp h

/-! ## LE/LT -/

/-! ## mul -/

lemma left_le_of_mul_le_mul [ordered_cancel_comm_monoid α] {a b : α} (c : α)
  (h : c * a ≤ c * b) : a ≤ b := (mul_le_mul_iff_left c).mp h

lemma right_le_of_mul_le_mul [ordered_cancel_comm_monoid α] {a b : α} (c : α)
  (h : a * c ≤ b * c) : a ≤ b := (mul_le_mul_iff_right c).mp h

lemma left_lt_of_mul_lt_mul [ordered_cancel_comm_monoid α] {a b : α} (c : α)
  (h : c * a < c * b) : a < b := (mul_lt_mul_iff_left c).mp h

lemma right_lt_of_mul_lt_mul [ordered_cancel_comm_monoid α] {a b : α} (c : α)
  (h : a * c < b * c) : a < b := (mul_lt_mul_iff_right c).mp h

lemma left_le_of_mul_le_mul' [linear_ordered_comm_group_with_zero α] {a b : α} (c : α)
  (h : c * a ≤ c * b) (h0 : c ≠ 0) : a ≤ b :=
by simpa only [inv_mul_cancel_left' h0] using (mul_le_mul_left' h c⁻¹)
-- TODO: PR ↑ to mathlib

lemma right_le_of_mul_le_mul' [linear_ordered_comm_group_with_zero α] {a b : α} (c : α)
  (h : a * c ≤ b * c) (h0 : c ≠ 0) : a ≤ b := le_of_le_mul_right h0 h

lemma left_lt_of_mul_lt_mul' [linear_ordered_comm_group_with_zero α] {a b : α} (c : α)
  (h : c * a < c * b) : a < b :=
by { contrapose! h, exact mul_le_mul_left' h c }
-- TODO: PR ↑ to mathlib?

lemma right_lt_of_mul_lt_mul' [linear_ordered_comm_group_with_zero α] {a b : α} (c : α)
  (h : a * c < b * c) : a < b :=
by { contrapose! h, exact mul_le_mul_right' h c }
-- TODO: PR ↑ to mathlib?

section linear_ordered_semiring
variables [linear_ordered_semiring α] {a b : α} (c : α)

lemma left_le_of_mul_le_mul_pos
  (h : c * a ≤ c * b) (h0 : 0 < c) : a ≤ b := (mul_le_mul_left h0).mp h

lemma right_le_of_mul_le_mul_pos
  (h : a * c ≤ b * c) (h0 : 0 < c) : a ≤ b := (mul_le_mul_right h0).mp h

lemma left_lt_of_mul_lt_mul_pos
  (h : c * a < c * b) (h0 : 0 < c) : a < b := (mul_lt_mul_left h0).mp h

lemma right_lt_of_mul_lt_mul_pos
  (h : a * c < b * c) (h0 : 0 < c) : a < b := (mul_lt_mul_right h0).mp h

end linear_ordered_semiring

section linear_ordered_ring
variables [linear_ordered_ring α] {a b : α} (c : α)

lemma left_le_of_mul_le_mul_neg
  (h : c * a ≤ c * b) (h0 : c < 0) : b ≤ a := (mul_le_mul_left_of_neg h0).mp h

lemma right_le_of_mul_le_mul_neg
  (h : a * c ≤ b * c) (h0 : c < 0) : b ≤ a := (mul_le_mul_right_of_neg h0).mp h

lemma left_lt_of_mul_lt_mul_neg
  (h : c * a < c * b) (h0 : c < 0) : b < a := (mul_lt_mul_left_of_neg h0).mp h

lemma right_lt_of_mul_lt_mul_neg
  (h : a * c < b * c) (h0 : c < 0) : b < a := (mul_lt_mul_right_of_neg h0).mp h

end linear_ordered_ring

/-! ### add -/

lemma left_le_of_add_le_add [ordered_cancel_add_comm_monoid α] {a b : α} (c : α)
  (h : c + a ≤ c + b) : a ≤ b := (add_le_add_iff_left c).mp h

lemma right_le_of_add_le_add [ordered_cancel_add_comm_monoid α] {a b : α} (c : α)
  (h : a + c ≤ b + c) : a ≤ b := (add_le_add_iff_right c).mp h

lemma left_lt_of_add_lt_add [ordered_cancel_add_comm_monoid α] {a b : α} (c : α)
  (h : c + a < c + b) : a < b := (add_lt_add_iff_left c).mp h

lemma right_lt_of_add_lt_add [ordered_cancel_add_comm_monoid α] {a b : α} (c : α)
  (h : a + c < b + c) : a < b := (add_lt_add_iff_right c).mp h

/-! ### sub -/

lemma left_le_of_sub_le_sub [ordered_add_comm_group α] {a b : α} (c : α)
  (h : c - a ≤ c - b) : b ≤ a := (sub_le_sub_iff_left c).mp h

lemma right_le_of_sub_le_sub [ordered_add_comm_group α] {a b : α} (c : α)
  (h : a - c ≤ b - c) : a ≤ b := (sub_le_sub_iff_right c).mp h

lemma left_lt_of_sub_lt_sub [ordered_add_comm_group α] {a b : α} (c : α)
  (h : c - a < c - b) : b < a := (sub_lt_sub_iff_left c).mp h

lemma right_lt_of_sub_lt_sub [ordered_add_comm_group α] {a b : α} (c : α)
  (h : a - c < b - c) : a < b := (sub_lt_sub_iff_right c).mp h

/-! ### inv -/

lemma le_of_inv_le_inv_pos [linear_ordered_field α] {a b : α}
  (h : a⁻¹ ≤ b⁻¹) (h0 : 0 < a) : b ≤ a :=
have hb : 0 < b, by { rw ← inv_pos at h0 ⊢, exact lt_of_lt_of_le h0 h },
(inv_le_inv h0 hb).mp h

lemma lt_of_inv_lt_inv_pos [linear_ordered_field α] {a b : α}
  (h : a⁻¹ < b⁻¹) (h0 : 0 < a) : b < a :=
have hb : 0 < b, by { rw ← inv_pos at h0 ⊢, exact lt_trans h0 h },
(inv_lt_inv h0 hb).mp h

lemma le_of_inv_le_inv_neg [linear_ordered_field α] {a b : α}
  (h : a⁻¹ ≤ b⁻¹) (h0 : b < 0) : b ≤ a :=
have ha : a < 0, by { rw ← inv_lt_zero at h0 ⊢, exact lt_of_le_of_lt h h0 },
(inv_le_inv_of_neg ha h0).mp h

lemma lt_of_inv_lt_inv_neg [linear_ordered_field α] {a b : α}
  (h : a⁻¹ < b⁻¹) (h0 : b < 0) : b < a :=
have ha : a < 0, by { rw ← inv_lt_zero at h0 ⊢, exact lt_trans h h0 },
(inv_lt_inv_of_neg ha h0).mp h

lemma le_of_inv_le_inv' [linear_ordered_comm_group_with_zero α] {a b : α}
  (h : a⁻¹ ≤ b⁻¹) (h0 : a ≠ 0) : b ≤ a :=
have hb : b ≠ 0, by { rintro rfl, rw [inv_zero, le_zero_iff, inv_eq_zero] at h, exact h0 h },
(inv_le_inv'' h0 hb).mp h

lemma lt_of_inv_lt_inv' [linear_ordered_comm_group_with_zero α] {a b : α}
  (h : a⁻¹ < b⁻¹) (h0 : a ≠ 0) : b < a :=
have hb : b ≠ 0, by { rintro rfl, rw [inv_zero] at h, exact not_lt_zero' h },
(inv_lt_inv'' h0 hb).mp h

lemma le_of_inv_le_inv'' [ordered_comm_group α] {a b : α}
  (h : a⁻¹ ≤ b⁻¹) : b ≤ a := inv_le_inv_iff.mp h

lemma lt_of_inv_lt_inv'' [ordered_comm_group α] {a b : α}
  (h : a⁻¹ < b⁻¹) : b < a := inv_lt_inv_iff.mp h

/-! ### neg -/

lemma le_of_neg_le_neg [ordered_add_comm_group α] {a b : α}
  (h : -a ≤ -b) : b ≤ a := neg_le_neg_iff.mp h

lemma lt_of_neg_lt_neg [ordered_add_comm_group α] {a b : α}
  (h : -a < -b) : b < a := neg_lt_neg_iff.mp h

/-! ### div -/

lemma right_le_of_div_le_div_pos [linear_ordered_field α] {a b : α} (c : α)
  (h : a / c ≤ b / c) (h0 : 0 < c) : a ≤ b :=
right_le_of_mul_le_mul_pos c⁻¹ h $ inv_pos.mpr h0

lemma right_le_of_div_le_div_neg [linear_ordered_field α] {a b : α} (c : α)
  (h : a / c ≤ b / c) (h0 : c < 0) : b ≤ a :=
right_le_of_mul_le_mul_neg c⁻¹ h $ inv_lt_zero.mpr h0

lemma right_lt_of_div_lt_div_pos [linear_ordered_field α] {a b : α} (c : α)
  (h : a / c < b / c) (h0 : 0 < c) : a < b :=
right_lt_of_mul_lt_mul_pos c⁻¹ h $ inv_pos.mpr h0

lemma right_lt_of_div_lt_div_neg [linear_ordered_field α] {a b : α} (c : α)
  (h : a / c < b / c) (h0 : c < 0) : b < a :=
right_lt_of_mul_lt_mul_neg c⁻¹ h $ inv_lt_zero.mpr h0

lemma left_le_of_div_le_div' [linear_ordered_comm_group_with_zero α] {a b : α} (c : α)
  (h : c / a ≤ c / b) (h0 : c ≠ 0) (ha : a ≠ 0) : b ≤ a :=
le_of_inv_le_inv' (left_le_of_mul_le_mul' c h h0) ha

lemma right_le_of_div_le_div' [linear_ordered_comm_group_with_zero α] {a b : α} (c : α)
  (h : a / c ≤ b / c) (h0 : c ≠ 0) : a ≤ b :=
right_le_of_mul_le_mul' (c⁻¹) h $ inv_ne_zero h0

lemma left_lt_of_div_lt_div' [linear_ordered_comm_group_with_zero α] {a b : α} (c : α)
  (h : c / a < c / b) (ha : a ≠ 0) : b < a :=
lt_of_inv_lt_inv' (left_lt_of_mul_lt_mul' c h) ha

lemma right_lt_of_div_lt_div' [linear_ordered_comm_group_with_zero α] {a b : α} (c : α)
  (h : a / c < b / c) : a < b :=
right_lt_of_mul_lt_mul' (c⁻¹) h

end standard_lemmas

@[derive [decidable_eq, has_reflect, inhabited]]
inductive side | L | R

@[derive [decidable_eq, has_reflect, inhabited]]
inductive op | mul | add | div | sub | inv | neg

@[derive [decidable_eq, has_reflect, inhabited]]
inductive sign | pos | neg

@[derive [decidable_eq, has_reflect, inhabited]]
inductive rel | eq | le | lt | ne -- can we pull this last one off?

open side op sign

def lookup_list : list ((side × op × option sign) × name) :=
[ /- EQ -/
  /- mul -/
  ((L, mul, none), `left_mul_cancel),
  ((R, mul, none), `right_mul_cancel),
  ((L, mul, none), `left_mul_cancel'),
  ((R, mul, none), `right_mul_cancel'),
  /- add -/
  ((L, add, none), `left_add_cancel),
  ((R, add, none), `right_add_cancel),
  /- div -/
  ((L, div, none), `left_div_cancel),
  ((R, div, none), `right_div_cancel),
  /- sub -/
  ((L, sub, none), `left_sub_cancel),
  ((R, sub, none), `right_sub_cancel),
  /- inv -/
  ((L, inv, none), `inv_cancel),  -- NB: the side argument doesn't really make sense here
  ((L, inv, none), `inv_cancel'),
  /- neg -/
  ((L, neg, none), `neg_cancel),
  /- LE/LT -/
  /- mul -/
  ((L, mul, none), `left_le_of_mul_le_mul),
  ((R, mul, none), `right_le_of_mul_le_mul),
  ((L, mul, none), `left_lt_of_mul_lt_mul),
  ((R, mul, none), `right_lt_of_mul_lt_mul),
  ((L, mul, none), `left_le_of_mul_le_mul'),
  ((R, mul, none), `right_le_of_mul_le_mul'),
  ((L, mul, none), `left_lt_of_mul_lt_mul'),
  ((R, mul, none), `right_lt_of_mul_lt_mul'),
  ((L, mul, pos ), `left_le_of_mul_le_mul_pos),
  ((R, mul, pos ), `right_le_of_mul_le_mul_pos),
  ((L, mul, pos ), `left_lt_of_mul_lt_mul_pos),
  ((R, mul, pos ), `right_lt_of_mul_lt_mul_pos),
  ((L, mul, neg ), `left_le_of_mul_le_mul_neg),
  ((R, mul, neg ), `right_le_of_mul_le_mul_neg),
  ((L, mul, neg ), `left_lt_of_mul_lt_mul_neg),
  ((R, mul, neg ), `right_lt_of_mul_lt_mul_neg),
  /- add -/
  ((L, add, none), `left_le_of_add_le_add),
  ((R, add, none), `right_le_of_add_le_add),
  ((L, add, none), `left_lt_of_add_lt_add),
  ((R, add, none), `right_lt_of_add_lt_add),
  /- div -/
  ((R, div, pos ), `right_le_of_div_le_div_pos),
  ((R, div, neg ), `right_le_of_div_le_div_neg),
  ((R, div, pos ), `right_lt_of_div_lt_div_pos),
  ((R, div, neg ), `right_lt_of_div_lt_div_neg),
  ((L, div, none), `left_le_of_div_le_div'),
  ((R, div, none), `right_le_of_div_le_div'),
  ((L, div, none), `left_lt_of_div_lt_div'),
  ((R, div, none), `right_lt_of_div_lt_div'),
  /- sub -/
  ((L, sub, none), `left_le_of_sub_le_sub),
  ((R, sub, none), `right_le_of_sub_le_sub),
  ((L, sub, none), `left_lt_of_sub_lt_sub),
  ((R, sub, none), `right_lt_of_sub_lt_sub),
  /- inv -/
  ((L, inv, pos ), `le_of_inv_le_inv_pos), -- the side `L` doesn't make sense here
  ((L, inv, neg ), `le_of_inv_le_inv_neg),
  ((L, inv, pos ), `lt_of_inv_lt_inv_pos),
  ((L, inv, neg ), `lt_of_inv_lt_inv_neg),
  ((L, inv, none), `le_of_inv_le_inv'),
  ((L, inv, none), `lt_of_inv_lt_inv'),
  ((L, inv, none), `le_of_inv_le_inv''),
  ((L, inv, none), `lt_of_inv_lt_inv''),
  /- neg -/
  ((L, neg, none), `le_of_neg_le_neg), -- the side `L` doesn't make sense here
  ((L, neg, none), `lt_of_neg_lt_neg)
  ]

/-
TODO:
special support for `0` and `1`? things like:
- `0 < x ↔ -x < 0`
- `(h : 0 ≤ x * y) (h0 : 0 ≤ 2) : 0 ≤ y`
- `1 < x ↔ x⁻¹ < 1`
-/

end baby_calc