/-
Copyright (c) 2020 Zhangir Azerbayev. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Zhangir Azerbayev.
-/

import linear_algebra.multilinear
import group_theory.perm.sign

/-!
# Alternating Maps

We construct the bundled function `alternating_map`, which extends `multilinear_map` with all the
arguments of the same type.

## Notation
For `R`-semimodules `M` and `N` and an index set `ι`, the structure of alternating multilinear maps
from`ι → M` into `N` is denoted `alternating_map R M N ι`. For some results, we must work with
`L` an `R-semimodule` that is also an `add_comm_group` and the structure `alternating_map R M L ι`.

## Theorems
1. `map_perm` asserts that for a map `f : alternating_map R M N ι`, and a
permutation `sigma` of `ι`, we have that `f ν = (sign σ) f (ν ∘ σ)`.
-/

variables (R : Type*) [semiring R]
variables (M : Type*) [add_comm_monoid M] [semimodule R M]
variables (N : Type*) [add_comm_monoid N] [semimodule R N]
variables (L : Type*) [add_comm_group L] [semimodule R L]
variables (ι : Type*) [decidable_eq ι]

/--
An alternating map is a multilinear map that vanishes when two of its arguments are equal.
-/
structure alternating_map extends multilinear_map R (λ i : ι, M) N :=
(map_alternating {ν : ι → M} {i j : ι} (h : ν i = ν j) (hij : i ≠ j) : to_fun ν = 0)

namespace alternating_map

variable {f : alternating_map R M N ι}
variable (ν : ι → M)
variables {R M N L ι}
open function

instance : has_coe (alternating_map R M N ι) (multilinear_map R (λ i : ι, M) N) :=
⟨λ x , ⟨x.to_fun, x.map_add', x.map_smul'⟩⟩

instance : has_coe_to_fun (alternating_map R M N ι) := by apply_instance

instance : inhabited (alternating_map R M N ι) :=
⟨⟨0, λ _ _ _ _ _, rfl⟩⟩

@[simp] lemma map_add (i : ι) (x y : M) :
  f (update ν i (x + y)) = f (update ν i x) + f (update ν i y) :=
f.to_multilinear_map.map_add' ν i x y

@[simp] lemma map_smul (i : ι) (r : R) (x : M) :
  f (update ν i (r • x)) = r • f (update ν i x) :=
f.to_multilinear_map.map_smul' ν i r x

lemma eq_args {i j : ι} (h : ν i = ν j) (hij : i ≠ j) : f ν = 0 := f.map_alternating h hij

lemma map_add_swap {i j : ι} (hij : i ≠ j) :
  f ν + f (ν ∘ equiv.swap i j) = 0 :=
begin
  have key : f (function.update (function.update ν i (ν i + ν j)) j (ν i + ν j)) = 0 :=
    by rw eq_args (function.update (function.update ν i (ν i + ν j)) j (ν i + ν j))
    (by rw [function.update_same, function.update_noteq hij,  function.update_same]) hij,
  rw map_add at key,
  rw [function.update_comm hij (ν i + ν j) (ν i) ν, map_add] at key,
  rw eq_args (function.update (function.update ν j (ν i)) i (ν i))
    (by rw [function.update_same, function.update_comm (ne_comm.mp hij) (ν i) (ν i) ν,
    function.update_same]) hij at key,
  rw zero_add at key,
  rw [function.update_comm hij (ν i + ν j) (ν j) ν, map_add] at key,
  rw eq_args (function.update (function.update ν j (ν j)) i (ν j))
  (by rw [function.update_same, function.update_comm (ne_comm.mp hij) (ν j) (ν j) ν,
  function.update_same]) hij at key,
  rw [add_zero, add_comm] at key,
  convert key,
  { simp,  },
  { ext x,
    cases classical.em (x = i) with hx hx,
    --case x = i
    { rw hx,
      simp only [equiv.swap_apply_left, function.comp_app],
      rw function.update_same,  },
    --case x ≠ i
    { cases classical.em (x = j) with hx1 hx1,
      { rw hx1,
        simp only [equiv.swap_apply_left, function.comp_app],
        rw function.update_noteq (ne_comm.mp hij),
        simp, },
    --case x ≠ i, x ≠ j,
      { simp only [hx, hx1, function.comp_app, function.update_noteq, ne.def, not_false_iff],
        rw equiv.swap_apply_of_ne_of_ne hx hx1, }, }, },
end

variable {g : alternating_map R M L ι}

lemma map_swap {i j : ι} (hij : i ≠ j) :
  g (ν ∘ equiv.swap i j) = - g ν  :=
begin
  apply eq_neg_of_add_eq_zero,
  rw add_comm,
  exact map_add_swap ν hij,
end

variable [fintype ι]

lemma map_perm (σ : equiv.perm ι) :
  g ν = (equiv.perm.sign σ : ℤ) • g (ν ∘ σ) :=
begin
  apply equiv.perm.swap_induction_on' σ,
  { rw equiv.perm.sign_one,
    simp only [units.coe_one, one_smul, coe_fn_coe_base],
    congr,  },
  { intros s x y hxy hI,
    have assoc : ν ∘ (s * equiv.swap x y : equiv.perm ι) = (ν ∘ s ∘ equiv.swap x y) := rfl,
    rw [assoc, map_swap (ν ∘ s) hxy, ←neg_one_smul ℤ (g (ν ∘ s))],
    have h1 : (-1 : ℤ) = equiv.perm.sign (equiv.swap x y) := by simp [hxy],
    rw [h1, smul_smul, ←units.coe_mul, ←equiv.perm.sign_mul, mul_assoc, equiv.swap_mul_self,
      mul_one],
    assumption, },
end

end alternating_map
