-- this should all be moved

-- import algebra.inj_surj
import data.nat.choose
import data.int.gcd
import data.mv_polynomial
import data.zmod.basic
import data.fintype.card
import ring_theory.multiplicity
import algebra.invertible
import number_theory.basic

universes u v w u₁

-- ### FOR_MATHLIB
-- everything in this file should move to other files


namespace alg_hom
open mv_polynomial

lemma comp_aeval {σ : Type*}
  {R : Type*} {A : Type*} {B : Type*}
   [comm_semiring R] [comm_semiring A] [algebra R A] [comm_semiring B] [algebra R B]
  (f : σ → A) (φ : A →ₐ[R] B) :
  φ.comp (aeval f) = (aeval (λ i, φ (f i))) :=
begin
  apply mv_polynomial.alg_hom_ext,
  intros i,
  rw [comp_apply, aeval_X, aeval_X],
end

end alg_hom

namespace mv_polynomial

open mv_polynomial finsupp

lemma eval₂_assoc'
  {S : Type*} [comm_semiring S]
  {T : Type*} [comm_semiring T]
  {σ : Type*}
  {τ : Type*}
  (f : S →+* T)
  (φ : σ → T) (q : τ → mv_polynomial σ S)
  (p : mv_polynomial τ S) :
  eval₂ f (λ t, eval₂ f φ (q t)) p = eval₂ f φ (eval₂ C q p) :=
show eval₂ f (λ t, eval₂_hom f φ (q t)) p = eval₂_hom f φ (eval₂ C q p),
by { rw eval₂_comp_left (eval₂_hom f φ), congr, ext, simp, }


noncomputable def map_hom
  {S : Type*} [comm_semiring S]
  {T : Type*} [comm_semiring T]
  {σ : Type*}
  (f : S →+* T) :
  mv_polynomial σ S →+* mv_polynomial σ T :=
ring_hom.of (mv_polynomial.map f)

section
variables {σ : Type*} {R : Type*} {S : Type*} {T : Type*}
variables [comm_semiring R] [comm_semiring S] [comm_semiring T] (f : R →+* S)

@[simp] lemma map_hom_C (r : R) : map_hom f (C r : mv_polynomial σ R) = C (f r) :=
map_C f r

@[simp] lemma map_hom_X (i : σ) : map_hom f (X i : mv_polynomial σ R) = X i :=
map_X f i

@[simp] lemma map_hom_rename {τ : Type*} (g : σ → τ) (p : mv_polynomial σ R) :
  map_hom f (rename g p) = rename g (map_hom f p) :=
map_rename f g p

@[simp] lemma eval₂_hom_rename {τ : Type*} (g : τ → S) (h : σ → τ) (p : mv_polynomial σ R) :
  eval₂_hom f g (rename h p) = eval₂_hom f (g ∘ h) p :=
eval₂_rename f h g p -- Achtung die Reihenfolge!

end

lemma map_eval₂'
  {R : Type*} [comm_semiring R]
  {S : Type*} [comm_semiring S]
  {T : Type*} [comm_semiring T]
  {σ : Type*}
  (φ : S →+* T)
  (f : R →+* S)
  (g : σ → S)
  (p : mv_polynomial σ R) :
  φ (eval₂ f g p) = eval₂ (φ.comp f) (λ i, φ (g i)) p :=
begin
  apply p.induction_on,
  { intros, rw [eval₂_C, eval₂_C, ring_hom.coe_comp] },
  { intros p₁ p₂ hp₁ hp₂, rw [eval₂_add, eval₂_add, ring_hom.map_add, hp₁, hp₂] },
  { intros q n h, rw [eval₂_mul, eval₂_mul, ring_hom.map_mul, eval₂_X, eval₂_X, h] }
end


section
variables {σ : Type*} {R : Type*} {A : Type*} {B : Type*}
   [comm_semiring R] [comm_semiring A] [comm_semiring B]


lemma aeval_eq_eval₂_hom' [algebra R A] (f : σ → A) (p : mv_polynomial σ R) :
  aeval f p = eval₂_hom (algebra_map R A) f p := rfl

@[simp] lemma eval₂_hom_C (f : R →+* A) (g : σ → A) (r : R) :
  eval₂_hom f g (C r) = f r := eval₂_C f g r

@[simp] lemma eval₂_hom_X' (f : R →+* A) (g : σ → A) (i : σ) :
  eval₂_hom f g (X i) = g i := eval₂_X f g i

@[simp] lemma comp_eval₂_hom (f : R →+* A) (g : σ → A) (φ : A →+* B) :
  φ.comp (eval₂_hom f g) = (eval₂_hom (φ.comp f) (λ i, φ (g i))) :=
begin
  apply mv_polynomial.ring_hom_ext,
  { intro r, rw [ring_hom.comp_apply, eval₂_hom_C, eval₂_hom_C, ring_hom.comp_apply] },
  { intro i, rw [ring_hom.comp_apply, eval₂_hom_X', eval₂_hom_X'] }
end

@[simp] lemma map_eval₂_hom (f : R →+* A) (g : σ → A) (φ : A →+* B) (p : mv_polynomial σ R) :
  φ (eval₂_hom f g p) = (eval₂_hom (φ.comp f) (λ i, φ (g i)) p) :=
by { rw ← comp_eval₂_hom, refl }

@[simp] lemma map_aeval [algebra R A]
  (g : σ → A) (φ : A →+* B) (p : mv_polynomial σ R) :
  φ (aeval g p) = (eval₂_hom (φ.comp (algebra_map R A)) (λ i, φ (g i)) p) :=
by { rw ← comp_eval₂_hom, refl }

@[simp] lemma eval_map (f : R →+* A) (g : σ → A) (p : mv_polynomial σ R) :
  eval g (map f p) = eval₂ f g p :=
by { apply mv_polynomial.induction_on p; { simp { contextual := tt } } }

@[simp] lemma eval₂_map (f : R →+* A) (g : σ → B) (φ : A →+* B) (p : mv_polynomial σ R) :
  eval₂ φ g (map f p) = eval₂ (φ.comp f) g p :=
by { rw [← eval_map, ← eval_map, map_map], }

@[simp] lemma eval₂_hom_map_hom (f : R →+* A) (g : σ → B) (φ : A →+* B) (p : mv_polynomial σ R) :
  eval₂_hom φ g (map_hom f p) = eval₂_hom (φ.comp f) g p :=
eval₂_map f g φ p

end

open_locale big_operators

lemma C_dvd_iff_dvd_coeff {σ : Type*} {R : Type*} [comm_ring R]
  (r : R) (φ : mv_polynomial σ R) :
  C r ∣ φ ↔ ∀ i, r ∣ (φ.coeff i) :=
begin
  split,
  { rintros ⟨φ, rfl⟩ c, rw coeff_C_mul, apply dvd_mul_right },
  { intro h,
    choose c hc using h,
    classical,
    let c' : (σ →₀ ℕ) → R := λ i, if i ∈ φ.support then c i else 0,
    let ψ : mv_polynomial σ R := ∑ i in φ.support, monomial i (c' i),
    use ψ,
    apply mv_polynomial.ext, intro i,
    simp only [coeff_C_mul, coeff_sum, coeff_monomial],
    rw [finset.sum_eq_single i, if_pos rfl],
    { dsimp [c'], split_ifs with hi hi,
      { rw hc },
      { rw finsupp.not_mem_support_iff at hi, rwa [mul_zero] } },
    { intros j hj hji, convert if_neg hji },
    { intro hi, rw [if_pos rfl], exact if_neg hi } }
end

-- why the hack does ring_hom.ker not exist!!!

lemma C_dvd_iff_map_hom_eq_zero {σ : Type*} {R : Type*} {S : Type*} [comm_ring R] [comm_ring S]
  (q : R →+* S) (hq : function.surjective q) (r : R) (hr : ∀ r' : R, q r' = 0 ↔ r ∣ r')
  (φ : mv_polynomial σ R) :
  C r ∣ φ ↔ map_hom q φ = 0 :=
begin
  rw C_dvd_iff_dvd_coeff,
  split,
  { intro h, apply mv_polynomial.ext, intro i,
    simp only [map_hom, coeff_map, *, ring_hom.coe_of, coeff_zero], },
  { rw mv_polynomial.ext_iff,
    simp only [map_hom, coeff_map, *, ring_hom.coe_of, coeff_zero, imp_self] }
end

lemma C_dvd_iff_zmod {σ : Type*} (n : ℕ) (φ : mv_polynomial σ ℤ) :
  C (n:ℤ) ∣ φ ↔ map_hom (int.cast_ring_hom (zmod n)) φ = 0 :=
begin
  apply C_dvd_iff_map_hom_eq_zero,
  { exact zmod.int_cast_surjective },
  { exact char_p.int_cast_eq_zero_iff (zmod n) n, }
end

end mv_polynomial

section
open multiplicity

lemma coe_nat_dvd {R : Type*} [comm_semiring R] (m n : ℕ) (h : m ∣ n) :
  (m : R) ∣ n :=
ring_hom.map_dvd (nat.cast_ring_hom R) h

lemma coe_int_dvd {R : Type*} [comm_ring R] (m n : ℤ) (h : m ∣ n) :
  (m : R) ∣ n :=
ring_hom.map_dvd (int.cast_ring_hom R) h

end


namespace invertible
variables {R : Type*} {S : Type*} [monoid R] [monoid S]

def copy {r : R} (hr : invertible r) (s : R) (hs : s = r) : invertible s :=
{ inv_of := ⅟r,
  inv_of_mul_self := by rw [hs, inv_of_mul_self],
  mul_inv_of_self := by rw [hs, mul_inv_of_self] }

end invertible

namespace mv_polynomial
noncomputable instance invertible_C
  (σ : Type*) {R : Type*} [comm_semiring R] (r : R) [invertible r] :
  invertible (C r : mv_polynomial σ R) :=
invertible.map ⟨C, C_1, λ x y, C_mul⟩ _

-- name??
noncomputable def invertible_rat_coe_nat (σ : Type*) (p : ℕ) [invertible (p : ℚ)] :
  invertible (p : mv_polynomial σ ℚ) :=
(mv_polynomial.invertible_C σ (p:ℚ)).copy p $ (C_eq_coe_nat p).symm

end mv_polynomial

namespace mv_polynomial
variables {σ : Type*} {R : Type*} [comm_semiring R]

@[simp] lemma alg_hom_C (f : mv_polynomial σ R →ₐ[R] mv_polynomial σ R) (r : R) :
  f (C r) = C r :=
f.commutes r

end mv_polynomial

namespace mv_polynomial
variables (R A : Type*) [comm_semiring R] [comm_semiring A] [algebra R A]

noncomputable def counit : mv_polynomial A R →ₐ A :=
aeval id

lemma counit_surjective : function.surjective (mv_polynomial.counit R A) :=
λ r, ⟨X r, eval₂_hom_X' _ _ _⟩

end mv_polynomial

namespace mv_polynomial
variables {σ : Type*} {τ : Type*} {υ : Type*} {R : Type*} [comm_semiring R]

/-- This is an example of a map of “algebraic varieties for dummies” over `R`.
(Not meant in a degrading way. Just that we don'y have any actual varieties in Lean yet.) -/
noncomputable def comap (f : mv_polynomial σ R →ₐ[R] mv_polynomial τ R) :
  (τ → R) → (σ → R) :=
λ x i, aeval x (f (X i))

@[simp] lemma comap_apply (f : mv_polynomial σ R →ₐ[R] mv_polynomial τ R) (x : τ → R) (i : σ) :
  comap f x i = aeval x (f (X i)) := rfl

@[simp] lemma comap_id_apply (x : σ → R) : comap (alg_hom.id R (mv_polynomial σ R)) x = x :=
by { funext i, simp only [comap, alg_hom.id_apply, id.def, aeval_X], }

variables (σ R)

lemma comap_id : comap (alg_hom.id R (mv_polynomial σ R)) = id :=
by { funext x, exact comap_id_apply x }

variables {σ R}

lemma comap_comp_apply (f : mv_polynomial σ R →ₐ[R] mv_polynomial τ R)
  (g : mv_polynomial τ R →ₐ[R] mv_polynomial υ R) (x : υ → R) :
  comap (g.comp f) x = (comap f) (comap g x) :=
begin
  funext i,
  transitivity (aeval x (aeval (λ i, g (X i)) (f (X i)))),
  { apply eval₂_hom_congr rfl rfl,
    rw alg_hom.comp_apply,
    suffices : g = aeval (λ i, g (X i)), { rw ← this, },
    apply mv_polynomial.alg_hom_ext g,
    intro, rw [aeval_X], },
  { simp only [comap, aeval_eq_eval₂_hom', map_eval₂_hom, alg_hom.comp_apply],
    refine eval₂_hom_congr _ rfl rfl,
    ext r, apply aeval_C },
end

lemma comap_comp (f : mv_polynomial σ R →ₐ[R] mv_polynomial τ R)
  (g : mv_polynomial τ R →ₐ[R] mv_polynomial υ R) (x : υ → R) :
  comap (g.comp f) = (comap f) ∘ (comap g) :=
by { funext x, exact comap_comp_apply _ _ _ }

lemma comap_eq_id_of_eq_id (f : mv_polynomial σ R →ₐ[R] mv_polynomial σ R)
  (hf : ∀ φ, f φ = φ) (x : σ → R) :
  comap f x = x :=
by { convert comap_id_apply x, ext1 φ, rw [hf, alg_hom.id_apply] }

noncomputable def comap_equiv (f : mv_polynomial σ R ≃ₐ[R] mv_polynomial τ R) :
  (τ → R) ≃ (σ → R) :=
{ to_fun    := comap f,
  inv_fun   := comap f.symm,
  left_inv  := by { intro x, rw [← comap_comp_apply], apply comap_eq_id_of_eq_id, intro,
    simp only [alg_hom.id_apply, alg_equiv.comp_symm], },
  right_inv := by { intro x, rw [← comap_comp_apply], apply comap_eq_id_of_eq_id, intro,
  simp only [alg_hom.id_apply, alg_equiv.symm_comp] }, }

@[simp] lemma comap_equiv_coe (f : mv_polynomial σ R ≃ₐ[R] mv_polynomial τ R) :
  (comap_equiv f : (τ → R) → (σ → R)) = comap f := rfl

@[simp] lemma comap_equiv_symm_coe (f : mv_polynomial σ R ≃ₐ[R] mv_polynomial τ R) :
  ((comap_equiv f).symm : (σ → R) → (τ → R)) = comap f.symm := rfl

lemma equiv_of_family_aux (f : σ → mv_polynomial τ R) (g : τ → mv_polynomial σ R)
  (h : ∀ i, aeval g (f i) = X i) (φ : mv_polynomial σ R) :
  (aeval g) (aeval f φ) = φ :=
begin
  rw ← alg_hom.comp_apply,
  suffices : (aeval g).comp (aeval f) = alg_hom.id _ _,
  { rw [this, alg_hom.id_apply], },
  refine mv_polynomial.alg_hom_ext _ (alg_hom.id _ _) _,
  intro i,
  rw [alg_hom.comp_apply, alg_hom.id_apply, aeval_X, h],
end

noncomputable def equiv_of_family (f : σ → mv_polynomial τ R) (g : τ → mv_polynomial σ R)
  (hfg : ∀ i, aeval g (f i) = X i) (hgf : ∀ i, aeval f (g i) = X i) :
  mv_polynomial σ R ≃ₐ[R] mv_polynomial τ R :=
{ to_fun    := aeval f,
  inv_fun   := aeval g,
  left_inv  := equiv_of_family_aux f g hfg,
  right_inv := equiv_of_family_aux g f hgf,
  .. aeval f}

@[simp] lemma equiv_of_family_coe (f : σ → mv_polynomial τ R) (g : τ → mv_polynomial σ R)
  (hfg : ∀ i, aeval g (f i) = X i) (hgf : ∀ i, aeval f (g i) = X i) :
  (equiv_of_family f g hfg hgf : mv_polynomial σ R →ₐ[R] mv_polynomial τ R) = aeval f := rfl

@[simp] lemma equiv_of_family_symm_coe (f : σ → mv_polynomial τ R) (g : τ → mv_polynomial σ R)
  (hfg : ∀ i, aeval g (f i) = X i) (hgf : ∀ i, aeval f (g i) = X i) :
  ((equiv_of_family f g hfg hgf).symm : mv_polynomial τ R →ₐ[R] mv_polynomial σ R) = aeval g := rfl

@[simp] lemma equiv_of_family_apply (f : σ → mv_polynomial τ R) (g : τ → mv_polynomial σ R)
  (hfg : ∀ i, aeval g (f i) = X i) (hgf : ∀ i, aeval f (g i) = X i)
  (φ : mv_polynomial σ R) :
  equiv_of_family f g hfg hgf φ = aeval f φ := rfl

@[simp] lemma equiv_of_family_symm_apply (f : σ → mv_polynomial τ R) (g : τ → mv_polynomial σ R)
  (hfg : ∀ i, aeval g (f i) = X i) (hgf : ∀ i, aeval f (g i) = X i)
  (φ : mv_polynomial τ R) :
  (equiv_of_family f g hfg hgf).symm φ = aeval g φ := rfl

-- I think this stuff should move back to the witt_vector file
namespace witt_structure_machine
variable {idx : Type*}
variables (f : σ → mv_polynomial τ R) (g : τ → mv_polynomial σ R)
variables (hfg : ∀ i, aeval g (f i) = X i) (hgf : ∀ i, aeval f (g i) = X i)

noncomputable def structure_polynomial (Φ : mv_polynomial idx R) (t : τ) :
  mv_polynomial (idx × τ) R :=
aeval (λ s : σ, (aeval (λ i, (rename (λ t', (i,t')) (f s)))) Φ) (g t)

include hfg

theorem structure_polynomial_prop (Φ : mv_polynomial idx R) (s : σ) :
  aeval (structure_polynomial f g Φ) (f s) = aeval (λ b, (rename (λ i, (b,i)) (f s))) Φ :=
calc aeval (structure_polynomial f g Φ) (f s) =
      aeval (λ s', aeval (λ b, (rename (prod.mk b)) (f s')) Φ) (aeval g (f s)) :
      by { conv_rhs { rw [aeval_eq_eval₂_hom', map_aeval] },
           apply eval₂_hom_congr _ rfl rfl,
           ext1 r, symmetry, apply eval₂_hom_C, }
... = aeval (λ i, (rename (λ t', (i,t')) (f s))) Φ : by rw [hfg, aeval_X]

include hgf

theorem exists_unique (Φ : mv_polynomial idx R) :
  ∃! (φ : τ → mv_polynomial (idx × τ) R),
    ∀ (s : σ), aeval φ (f s) = aeval (λ i, (rename (λ t', (i,t')) (f s))) Φ :=
begin
  refine ⟨structure_polynomial f g Φ, structure_polynomial_prop _ _ hfg _, _⟩,
  { intros φ H,
    funext t,
    calc φ t = aeval φ (aeval (f) (g t))    : by rw [hgf, aeval_X]
         ... = structure_polynomial f g Φ t : _,
    rw [aeval_eq_eval₂_hom', map_aeval],
    apply eval₂_hom_congr _ _ rfl,
    { ext1 r, exact eval₂_C _ _ r, },
    { funext k, exact H k } }
end

end witt_structure_machine

end mv_polynomial

-- ### end FOR_MATHLIB
