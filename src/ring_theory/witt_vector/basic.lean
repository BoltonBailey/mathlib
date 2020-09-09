/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Rob Lewis
-/

import ring_theory.witt_vector.witt_vector_preps
import ring_theory.witt_vector.structure_polynomial

/-!
# Witt vectors

## Main definitions
TODO

## Notation
TODO

## Implementation details
TODO
-/

/-- `witt_vector p R` is the ring of `p`-typical Witt vectors over the commutative ring `R`,
where `p` is a prime number.

If `p` is invertible in `R`, this ring is isomorphic to `ℕ → R` (the product of `ℕ` copies of `R`).
If `R` is a ring of characteristic `p`, then `witt_vector p R` is a ring of characteristic `0`.
The canonical example is `witt_vector p (zmod p)`,
which is isomorphic to the `p`-adic integers `ℤ_[p]`. -/
def witt_vector (p : ℕ) (R : Type*) := ℕ → R

variables {p : ℕ}
-- TODO: make this localized notation??
local notation `𝕎` := witt_vector p -- type as `\bbW`

namespace witt_vector

variables (p) {R : Type*}

def mk (x : ℕ → R) : witt_vector p R := x

/-
-- Witt coefficients

I don't know a name for this map in the literature. But coefficient seems ok.
-/

def coeff (n : ℕ) (x : 𝕎 R) : R := x n

@[ext]
lemma ext {x y : 𝕎 R} (h : ∀ n, x.coeff n = y.coeff n) : x = y :=
funext $ λ n, h n

lemma ext_iff {x y : 𝕎 R} : x = y ↔ ∀ n, x.coeff n = y.coeff n :=
⟨λ h n, by rw h, ext⟩

@[simp] lemma coeff_mk (x : ℕ → R) (i : ℕ) :
  (mk p x).coeff i = x i := rfl

-- do we want to keep these two?
instance : functor (witt_vector p) :=
{ map := λ α β f v, f ∘ v,
  map_const := λ α β a v, λ _, a }

instance : is_lawful_functor (witt_vector p) :=
{ map_const_eq := λ α β, rfl,
  id_map := λ α v, rfl,
  comp_map := λ α β γ f g v, rfl }

end witt_vector

universes u v w u₁
open mv_polynomial
open set
open finset (range)
open finsupp (single)

open_locale big_operators

local attribute [-simp] coe_eval₂_hom

variables (p) {R S T : Type*} [comm_ring R] [comm_ring S] [comm_ring T]

open_locale witt

namespace witt_vector

section ring_data
variables (R) [fact p.prime]

noncomputable instance : has_zero (𝕎 R) :=
⟨λ n, aeval (λ p : empty × ℕ, p.1.elim) (witt_zero p n)⟩

noncomputable instance : has_one (𝕎 R) :=
⟨λ n, aeval (λ p : empty × ℕ, p.1.elim) (witt_one p n)⟩

noncomputable instance : has_add (𝕎 R) :=
⟨λ x y n, aeval (λ bn : bool × ℕ, cond bn.1 (x bn.2) (y bn.2)) (witt_add p n)⟩

noncomputable instance : has_mul (𝕎 R) :=
⟨λ x y n, aeval (λ bn : bool × ℕ, cond bn.1 (x bn.2) (y bn.2)) (witt_mul p n)⟩

noncomputable instance : has_neg (𝕎 R) :=
⟨λ x n, aeval (λ n : unit × ℕ, x n.2) (witt_neg p n)⟩

end ring_data

variables {p} {R}

section map
open function
variables {α : Type*} {β : Type*}

def map_fun (f : α → β) : 𝕎 α → 𝕎 β := λ x, f ∘ x

lemma map_fun_injective (f : α → β) (hf : injective f) :
  injective (map_fun f : 𝕎 α → 𝕎 β) :=
λ x y h, funext $ λ n, hf $ by exact congr_fun h n

lemma map_fun_surjective (f : α → β) (hf : surjective f) :
  surjective (map_fun f : 𝕎 α → 𝕎 β) :=
λ x, ⟨λ n, classical.some $ hf $ x n,
by { funext n, dsimp [map_fun], rw classical.some_spec (hf (x n)) }⟩

variables (f : R →+* S)

/-- Auxiliary tactic for showing that `witt_package.map` respects ring data. -/
meta def witt_map : tactic unit :=
`[funext n,
  show f (aeval _ _) = aeval _ _,
  rw map_aeval,
  apply eval₂_hom_congr (ring_hom.ext_int _ _) _ rfl,
  funext p,
  rcases p with ⟨⟨⟩, i⟩; refl]

variable [fact p.prime]

@[simp] lemma map_fun_zero : map_fun f (0 : 𝕎 R) = 0 :=
by witt_map

@[simp] lemma map_fun_one : map_fun f (1 : 𝕎 R) = 1 :=
by witt_map

@[simp] lemma map_fun_add (x y : 𝕎 R) :
  map_fun f (x + y) = map_fun f x + map_fun f y :=
by witt_map

@[simp] lemma map_fun_mul (x y : 𝕎 R) :
  map_fun f (x * y) = map_fun f x * map_fun f y :=
by witt_map

@[simp] lemma map_fun_neg (x : 𝕎 R) :
  map_fun f (-x) = -map_fun f x :=
by witt_map

end map

section

noncomputable def ghost_component (n : ℕ) (x : 𝕎 R) : R :=
aeval x (W_ ℤ n)

lemma ghost_component_apply (n : ℕ) (x : 𝕎 R) :
  ghost_component n x = aeval x (W_ ℤ n) := rfl

lemma ghost_component_apply' (n : ℕ) (x : 𝕎 R) :
  ghost_component n x = aeval x (W_ R n) :=
begin
  simp only [ghost_component_apply, aeval_eq_eval₂_hom,
    ← map_witt_polynomial p (int.cast_ring_hom R), eval₂_hom_map_hom],
  exact eval₂_hom_congr (ring_hom.ext_int _ _) rfl rfl,
end

noncomputable def ghost_map_fun : 𝕎 R → (ℕ → R) := λ w n, ghost_component n w

end

end witt_vector

section tactic
setup_tactic_parser
open tactic
meta def tactic.interactive.ghost_boo (poly fn: parse parser.pexpr) : tactic unit :=
do to_expr ```(witt_structure_int_prop p (%%poly) n) >>= note `aux none >>=
     apply_fun_to_hyp ```(aeval %%fn) none,
`[convert aux using 1; clear aux,
  simp only [aeval_eq_eval₂_hom, eval₂_hom_map_hom, map_eval₂_hom, bind₁];
  apply eval₂_hom_congr (ring_hom.ext_int _ _) _ rfl;
  funext k;
  exact eval₂_hom_congr (ring_hom.ext_int _ _) rfl rfl,
  all_goals { simp only [aeval_eq_eval₂_hom, ring_hom.map_add, ring_hom.map_one, ring_hom.map_neg,
                         ring_hom.map_mul, eval₂_hom_X', bind₁];
              simp only [coe_eval₂_hom, eval₂_rename];
              refl }]
end tactic

namespace witt_vector


section p_prime
open finset mv_polynomial function set

variable {p}
variables [comm_ring R] [comm_ring S] [comm_ring T]

@[simp] lemma ghost_map_fun_apply (x : 𝕎 R) (n : ℕ) :
  ghost_map_fun x n = ghost_component n x := rfl

variable [hp : fact p.prime]
include hp

@[simp] lemma ghost_component_zero (n : ℕ) :
  ghost_component n (0 : 𝕎 R) = 0 :=
by ghost_boo (0 : mv_polynomial empty ℤ) (λ (p : empty × ℕ), (p.1.elim : R))

@[simp] lemma ghost_component_one (n : ℕ) :
  ghost_component n (1 : 𝕎 R) = 1 :=
by ghost_boo (1 : mv_polynomial empty ℤ) (λ (p : empty × ℕ), (p.1.elim : R))

variable {R}

@[simp] lemma ghost_component_add (n : ℕ) (x y : 𝕎 R) :
  ghost_component n (x + y) = ghost_component n x + ghost_component n y :=
by ghost_boo (X tt + X ff) (λ (bn : bool × ℕ), cond bn.1 (x bn.2) (y bn.2))

@[simp] lemma ghost_component_mul (n : ℕ) (x y : 𝕎 R) :
  ghost_component n (x * y) = ghost_component n x * ghost_component n y :=
by ghost_boo (X tt * X ff) (λ (bn : bool × ℕ), cond bn.1 (x bn.2) (y bn.2))

@[simp] lemma ghost_component_neg (n : ℕ) (x : 𝕎 R) :
  ghost_component n (-x) = - ghost_component n x :=
by ghost_boo (-X unit.star) (λ (n : unit × ℕ), (x n.2))

variables (R)

@[simp] lemma ghost_map_fun.zero : ghost_map_fun (0 : 𝕎 R) = 0 :=
by { ext n, simp only [pi.zero_apply, ghost_map_fun_apply, ghost_component_zero], }

@[simp] lemma ghost_map_fun.one : ghost_map_fun (1 : 𝕎 R) = 1 :=
by { ext n, simp only [pi.one_apply, ghost_map_fun_apply, ghost_component_one], }

variable {R}

@[simp] lemma ghost_map_fun.add (x y : 𝕎 R) :
  ghost_map_fun (x + y) = ghost_map_fun x + ghost_map_fun y :=
by { ext n, simp only [ghost_component_add, pi.add_apply, ghost_map_fun_apply], }

@[simp] lemma ghost_map_fun.mul (x y : 𝕎 R) :
  ghost_map_fun (x * y) = ghost_map_fun x * ghost_map_fun y :=
by { ext n, simp only [ghost_component_mul, pi.mul_apply, ghost_map_fun_apply], }

@[simp] lemma ghost_map_fun.neg (x : 𝕎 R) :
  ghost_map_fun (-x) = - ghost_map_fun x :=
by { ext n, simp only [ghost_component_neg, pi.neg_apply, ghost_map_fun_apply], }

end p_prime

variables (p) (R)

noncomputable def ghost_map_fun.equiv_of_invertible [invertible (p : R)] :
  𝕎 R ≃ (ℕ → R) :=
mv_polynomial.comap_equiv (witt.alg_equiv p R)

lemma ghost_map_fun_eq [invertible (p : R)] :
  (ghost_map_fun : 𝕎 R → ℕ → R) = ghost_map_fun.equiv_of_invertible p R :=
begin
  ext w n,
  rw [ghost_map_fun_apply, ghost_component_apply'],
  dsimp [ghost_map_fun.equiv_of_invertible, witt.alg_equiv],
  rw [aeval_X],
end

lemma ghost_map_fun.bijective_of_invertible [invertible (p : R)] :
  function.bijective (ghost_map_fun : 𝕎 R → ℕ → R) :=
by { rw ghost_map_fun_eq, exact (ghost_map_fun.equiv_of_invertible p R).bijective }

section
open function

variable (R)

noncomputable def mv_polynomial.counit : mv_polynomial R ℤ →+* R :=
eval₂_hom (int.cast_ring_hom R) id

lemma counit_surjective : surjective (mv_polynomial.counit R) :=
λ r, ⟨X r, eval₂_hom_X' _ _ _⟩

end

local attribute [instance] mv_polynomial.invertible_rat_coe_nat

variable (R)

variable [hp : fact p.prime]
include hp

private noncomputable def comm_ring_aux₁ : comm_ring (𝕎 (mv_polynomial R ℚ)) :=
function.injective.comm_ring (ghost_map_fun)
  (ghost_map_fun.bijective_of_invertible p (mv_polynomial R ℚ)).1
  (ghost_map_fun.zero _) (ghost_map_fun.one _) (ghost_map_fun.add) (ghost_map_fun.mul) (ghost_map_fun.neg)

local attribute [instance] comm_ring_aux₁

private noncomputable def comm_ring_aux₂ : comm_ring (𝕎 (mv_polynomial R ℤ)) :=
function.injective.comm_ring (map_fun $ mv_polynomial.map (int.cast_ring_hom ℚ))
  (map_fun_injective _ $ mv_polynomial.coe_int_rat_map_injective _)
  (map_fun_zero _) (map_fun_one _) (map_fun_add _) (map_fun_mul _) (map_fun_neg _)

local attribute [instance] comm_ring_aux₂

noncomputable instance : comm_ring (𝕎 R) :=
function.surjective.comm_ring
  (map_fun $ mv_polynomial.counit _) (map_fun_surjective _ $ counit_surjective _)
  (map_fun_zero _) (map_fun_one _) (map_fun_add _) (map_fun_mul _) (map_fun_neg _)

variables {p R}

section map
open function

noncomputable def map (f : R →+* S) : 𝕎 R →+* 𝕎 S :=
{ to_fun := map_fun f,
  map_zero' := map_fun_zero f,
  map_one' := map_fun_one f,
  map_add' := map_fun_add f,
  map_mul' := map_fun_mul f }

lemma map_injective (f : R →+* S) (hf : injective f) :
  injective (map f : 𝕎 R → 𝕎 S) :=
map_fun_injective f hf

lemma map_surjective (f : R →+* S) (hf : surjective f) :
  surjective (map f : 𝕎 R → 𝕎 S) :=
map_fun_surjective f hf

end map

noncomputable def ghost_map : 𝕎 R →+* ℕ → R :=
{ to_fun := ghost_map_fun,
  map_zero' := ghost_map_fun.zero R,
  map_one' := ghost_map_fun.one R,
  map_add' := ghost_map_fun.add,
  map_mul' := ghost_map_fun.mul }

@[simp] lemma ghost_map_apply (x : 𝕎 R) (n : ℕ) :
  ghost_map x n = ghost_component n x := rfl

variables (p R)

noncomputable def ghost_equiv [invertible (p : R)] : 𝕎 R ≃+* (ℕ → R) :=
{ inv_fun := (ghost_map_fun.equiv_of_invertible p R).inv_fun,
  left_inv :=
  begin
    dsimp [ghost_map], rw [ghost_map_fun_eq],
    exact (ghost_map_fun.equiv_of_invertible p R).left_inv
  end,
  right_inv :=
  begin
    dsimp [ghost_map], rw [ghost_map_fun_eq],
    exact (ghost_map_fun.equiv_of_invertible p R).right_inv
  end,
  .. (ghost_map : 𝕎 R →+* (ℕ → R)) }

lemma ghost_map.bijective_of_invertible [invertible (p : R)] :
  function.bijective (ghost_map : 𝕎 R → ℕ → R) :=
ghost_map_fun.bijective_of_invertible p R


section coeff

variables (p R)

@[simp] lemma zero_coeff (n : ℕ) : (0 : 𝕎 R).coeff n = 0 :=
show (aeval _ (witt_zero p n) : R) = 0,
by simp only [witt_zero_eq_zero, alg_hom.map_zero]

@[simp] lemma one_coeff_zero : (1 : 𝕎 R).coeff 0 = 1 :=
show (aeval _ (witt_one p 0) : R) = 1,
by simp only [witt_one_zero_eq_one, alg_hom.map_one]

@[simp] lemma one_coeff_pos (n : ℕ) (hn : 0 < n) : coeff n (1 : 𝕎 R) = 0 :=
show (aeval _ (witt_one p n) : R) = 0,
by simp only [hn, witt_one_pos_eq_zero, alg_hom.map_zero]

lemma add_coeff (x y : 𝕎 R) (n : ℕ) :
  (x + y).coeff n =
  aeval (λ bn : bool × ℕ, cond bn.1 (x.coeff bn.2) (y.coeff bn.2)) (witt_add p n) :=
rfl

lemma mul_coeff (x y : 𝕎 R) (n : ℕ) :
  (x * y).coeff n =
  aeval (λ bn : bool × ℕ, cond bn.1 (x.coeff bn.2) (y.coeff bn.2)) (witt_mul p n) :=
rfl

lemma neg_coeff (x : 𝕎 R) (n : ℕ) :
  (-x).coeff n = aeval (λ bn : unit × ℕ, (x.coeff bn.2)) (witt_neg p n) := rfl

lemma map_coeff (f : R →+* S) (x : 𝕎 R) (n : ℕ) :
  (map f x).coeff n = f (x.coeff n) := rfl

end coeff

end witt_vector

attribute [irreducible] witt_vector
