/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import category_theory.limits.shapes.biproducts
import category_theory.preadditive
-- import category_theory.simple
import tactic.abel

open category_theory
open category_theory.preadditive
open category_theory.limits

universes v u

namespace category_theory

variables {C : Type u} [category.{v} C]
section
variables [has_zero_morphisms.{v} C] [has_binary_biproducts.{v} C]

/--
If
```
(f 0)
(0 g)
```
is invertible, then `f` is invertible.
-/
def is_iso_left_of_is_iso_biprod_map
  {W X Y Z : C} (f : W ⟶ Y) (g : X ⟶ Z) [is_iso (biprod.map f g)] : is_iso f :=
{ inv := biprod.inl ≫ inv (biprod.map f g) ≫ biprod.fst,
  hom_inv_id' :=
  begin
    have t := congr_arg (λ p : W ⊞ X ⟶ W ⊞ X, biprod.inl ≫ p ≫ biprod.fst)
      (is_iso.hom_inv_id (biprod.map f g)),
    simp only [category.id_comp, category.assoc, biprod.inl_map_assoc] at t,
    simp [t],
  end,
  inv_hom_id' :=
  begin
    have t := congr_arg (λ p : Y ⊞ Z ⟶ Y ⊞ Z, biprod.inl ≫ p ≫ biprod.fst)
      (is_iso.inv_hom_id (biprod.map f g)),
    simp only [category.id_comp, category.assoc, biprod.map_fst] at t,
    simp only [category.assoc],
    simp [t],
  end }

def is_iso_right_of_is_iso_biprod_map
  {W X Y Z : C} (f : W ⟶ Y) (g : X ⟶ Z) [is_iso (biprod.map f g)] : is_iso g :=
begin
  haveI : is_iso (biprod.map g f) := by
  { rw [←biprod.braiding_map_braiding],
    apply_instance, },
  exact is_iso_left_of_is_iso_biprod_map g f,
end

end

section
variables [preadditive.{v} C] [has_binary_biproducts.{v} C]

variables {X₁ X₂ Y₁ Y₂ : C}
variables (f₁₁ : X₁ ⟶ Y₁) (f₁₂ : X₁ ⟶ Y₂) (f₂₁ : X₂ ⟶ Y₁) (f₂₂ : X₂ ⟶ Y₂)

def biprod.of_components : X₁ ⊞ X₂ ⟶ Y₁ ⊞ Y₂ :=
biprod.fst ≫ f₁₁ ≫ biprod.inl +
biprod.fst ≫ f₁₂ ≫ biprod.inr +
biprod.snd ≫ f₂₁ ≫ biprod.inl +
biprod.snd ≫ f₂₂ ≫ biprod.inr

@[simp]
lemma biprod.inl_of_components :
  biprod.inl ≫ biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂ =
    f₁₁ ≫ biprod.inl + f₁₂ ≫ biprod.inr :=
by simp [biprod.of_components]

@[simp]
lemma biprod.inr_of_components :
  biprod.inr ≫ biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂ =
    f₂₁ ≫ biprod.inl + f₂₂ ≫ biprod.inr :=
by simp [biprod.of_components]

@[simp]
lemma biprod.of_components_fst :
  biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂ ≫ biprod.fst =
    biprod.fst ≫ f₁₁ + biprod.snd ≫ f₂₁ :=
by simp [biprod.of_components]

@[simp]
lemma biprod.of_components_snd :
  biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂ ≫ biprod.snd =
    biprod.fst ≫ f₁₂ + biprod.snd ≫ f₂₂ :=
by simp [biprod.of_components]

@[simp]
lemma biprod.inl_of_components_fst :
  biprod.inl ≫ biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂ ≫ biprod.fst = f₁₁ :=
by simp [biprod.of_components]

@[simp]
lemma biprod.inl_of_components_snd :
  biprod.inl ≫ biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂ ≫ biprod.snd = f₁₂ :=
by simp [biprod.of_components]

@[simp]
lemma biprod.inr_of_components_fst :
  biprod.inr ≫ biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂ ≫ biprod.fst = f₂₁ :=
by simp [biprod.of_components]

@[simp]
lemma biprod.inr_of_components_snd :
  biprod.inr ≫ biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂ ≫ biprod.snd = f₂₂ :=
by simp [biprod.of_components]

@[simp]
lemma biprod.of_components_eq (f : X₁ ⊞ X₂ ⟶ Y₁ ⊞ Y₂) :
  biprod.of_components (biprod.inl ≫ f ≫ biprod.fst) (biprod.inl ≫ f ≫ biprod.snd)
    (biprod.inr ≫ f ≫ biprod.fst) (biprod.inr ≫ f ≫ biprod.snd) = f :=
begin
  ext; simp,
end

@[simp]
lemma biprod.of_components_comp {X₁ X₂ Y₁ Y₂ Z₁ Z₂ : C}
  (f₁₁ : X₁ ⟶ Y₁) (f₁₂ : X₁ ⟶ Y₂) (f₂₁ : X₂ ⟶ Y₁) (f₂₂ : X₂ ⟶ Y₂)
  (g₁₁ : Y₁ ⟶ Z₁) (g₁₂ : Y₁ ⟶ Z₂) (g₂₁ : Y₂ ⟶ Z₁) (g₂₂ : Y₂ ⟶ Z₂) :
  biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂ ≫ biprod.of_components g₁₁ g₁₂ g₂₁ g₂₂ =
    biprod.of_components (f₁₁ ≫ g₁₁ + f₁₂ ≫ g₂₁) (f₁₁ ≫ g₁₂ + f₁₂ ≫ g₂₂) (f₂₁ ≫ g₁₁ + f₂₂ ≫ g₂₁) (f₂₁ ≫ g₁₂ + f₂₂ ≫ g₂₂) :=
begin
  dsimp [biprod.of_components],
  apply biprod.hom_ext; apply biprod.hom_ext'; simp,
end

/--
The unipotent upper triangular matrix
```
(1 r)
(0 1)
```
as an isomorphism.
-/
@[simps]
def biprod.unipotent_upper {X₁ X₂ : C} (r : X₁ ⟶ X₂) : X₁ ⊞ X₂ ≅ X₁ ⊞ X₂ :=
{ hom := biprod.of_components (𝟙 _) r 0 (𝟙 _),
  inv := biprod.of_components (𝟙 _) (-r) 0 (𝟙 _), }

/--
The unipotent lower triangular matrix
```
(1 0)
(r 1)
```
as an isomorphism.
-/
@[simps]
def biprod.unipotent_lower {X₁ X₂ : C} (r : X₂ ⟶ X₁) : X₁ ⊞ X₂ ≅ X₁ ⊞ X₂ :=
{ hom := biprod.of_components (𝟙 _) 0 r (𝟙 _),
  inv := biprod.of_components (𝟙 _) 0 (-r) (𝟙 _), }


/--
If `X₁ ⊞ X₂ ≅ Y₁ ⊞ Y₂` via a two-by-two matrix whose `X₁ ⟶ Y₁` entry is an isomorphism,
then we can construct an isomorphism `X₂ ≅ Y₂`, via Gaussian elimination.
-/
def biprod.iso_elim' [is_iso f₁₁] [is_iso (biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂)] : X₂ ≅ Y₂ :=
begin
  -- We use Gaussian elimination to show that the matrix `f` is equivalent to a diagonal matrix,
  -- which then must be an isomorphism.
  set f := biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂,
  set a : X₁ ⊞ X₂ ≅ X₁ ⊞ X₂ := biprod.unipotent_lower (-(f₂₁ ≫ inv f₁₁)),
  set b : Y₁ ⊞ Y₂ ≅ Y₁ ⊞ Y₂ := biprod.unipotent_upper (-(inv f₁₁ ≫ f₁₂)),
  set r : X₂ ⟶ Y₂ := f₂₂ - f₂₁ ≫ (inv f₁₁) ≫ f₁₂,
  set d : X₁ ⊞ X₂ ⟶ Y₁ ⊞ Y₂ := biprod.map f₁₁ r,
  have w : a.hom ≫ f ≫ b.hom = d := by { ext; simp [f, a, b, d, r]; abel, },
  haveI : is_iso d := by { rw ←w, apply_instance, },
  haveI : is_iso r := (is_iso_right_of_is_iso_biprod_map f₁₁ r),
  exact as_iso r
end

/--
If `f` is an isomorphism `X₁ ⊞ X₂ ≅ Y₁ ⊞ Y₂` whose `X₁ ⟶ Y₁` entry is an isomorphism,
then we can construct an isomorphism `X₂ ≅ Y₂`, via Gaussian elimination.
-/
def biprod.iso_elim (f : X₁ ⊞ X₂ ≅ Y₁ ⊞ Y₂) [is_iso (biprod.inl ≫ f.hom ≫ biprod.fst)] : X₂ ≅ Y₂ :=
begin
  haveI : is_iso (biprod.of_components (biprod.inl ≫ f.hom ≫ biprod.fst) (biprod.inl ≫ f.hom ≫ biprod.snd)
       (biprod.inr ≫ f.hom ≫ biprod.fst)
       (biprod.inr ≫ f.hom ≫ biprod.snd)) :=
  by { simp only [biprod.of_components_eq], apply_instance, },
  exact biprod.iso_elim'
    (biprod.inl ≫ f.hom ≫ biprod.fst)
    (biprod.inl ≫ f.hom ≫ biprod.snd)
    (biprod.inr ≫ f.hom ≫ biprod.fst)
    (biprod.inr ≫ f.hom ≫ biprod.snd)
end

-- lemma biprod.row_nonzero_of_iso [is_iso (biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂)] :
--   𝟙 X₁ = 0 ∨ f₁₁ ≠ 0 ∨ f₁₂ ≠ 0 :=
-- begin
--   classical,
--   by_contradiction,
--   rw [not_or_distrib, not_or_distrib, classical.not_not, classical.not_not] at a,
--   set M := biprod.of_components f₁₁ f₁₂ f₂₁ f₂₂,
--   rcases a with ⟨nz, rfl, rfl⟩,
--   set X := inv M,
--   set x := biprod.inl ≫ M ≫ X ≫ biprod.fst,
--   have h₁ : x = 𝟙 _, by simp [x],
--   have h₀ : x = 0,
--   begin
--     dsimp [x, M, X],
--     conv_lhs {
--       slice 1 2,
--       rw [biprod.inl_of_components],
--     },
--     simp,
--   end,
--   exact nz (h₁.symm.trans h₀),
-- end

lemma biprod.column_nonzero_of_iso {W X Y Z : C}
  (f : W ⊞ X ⟶ Y ⊞ Z) [is_iso f] :
  𝟙 W = 0 ∨ biprod.inl ≫ f ≫ biprod.fst ≠ 0 ∨ biprod.inl ≫ f ≫ biprod.snd ≠ 0 :=
begin
  classical,
  by_contradiction,
  rw [not_or_distrib, not_or_distrib, classical.not_not, classical.not_not] at a,
  rcases a with ⟨nz, a₁, a₂⟩,
  set x := biprod.inl ≫ f ≫ inv f ≫ biprod.fst,
  have h₁ : x = 𝟙 W, by simp [x],
  have h₀ : x = 0,
  { dsimp [x],
    rw [←category.id_comp (inv f), category.assoc, ←biprod.total],
    conv_lhs { slice 2 3, rw [comp_add], },
    simp only [category.assoc],
    rw [comp_add_assoc, add_comp],
    conv_lhs { congr, skip, slice 1 3, rw a₂, },
    simp only [has_zero_morphisms.zero_comp, add_zero],
    conv_lhs { slice 1 3, rw a₁, },
    simp only [has_zero_morphisms.zero_comp], },
  exact nz (h₁.symm.trans h₀),
end


end

variables [preadditive.{v} C]
open_locale big_operators

lemma biproduct.column_nonzero_of_iso'
  {σ τ : Type v} [decidable_eq σ] [fintype σ] [decidable_eq τ] [fintype τ]
  {S : σ → C} [has_biproduct.{v} S] {T : τ → C} [has_biproduct.{v} T]
  (f : ⨁ S ⟶ ⨁ T) [is_iso f] (s : σ) :
  (∀ t : τ, biproduct.ι S s ≫ f ≫ biproduct.π T t = 0) → 𝟙 (S s) = 0 :=
begin
  intro z,
  set x := biproduct.ι S s ≫ f ≫ inv f ≫ biproduct.π S s,
  have h₁ : x = 𝟙 (S s), by simp [x],
  have h₀ : x = 0,
  { dsimp [x],
    rw [←category.id_comp (inv f), category.assoc, ←biproduct.total],
    simp only [comp_sum_assoc],
    conv_lhs { congr, apply_congr, skip, simp only [reassoc_of z], },
    simp, },
  exact h₁.symm.trans h₀,
end

/--
For `s : multiset α`, we can lift the existential statement that `∃ x, x ∈ s` to a `trunc α`.
-/
def trunc_of_multiset_exists_mem {α} (s : multiset α) : (∃ x, x ∈ s) → trunc α :=
quotient.rec_on_subsingleton s $ λ l h,
  match l, h with
    | [],       _ := false.elim (by tauto)
    | (a :: _), _ := trunc.mk a
  end

/--
A `nonempty` `fintype` constructively contains an element.
-/
def trunc_of_nonempty_fintype {α} (h : nonempty α) [fintype α] : trunc α :=
trunc_of_multiset_exists_mem finset.univ.val (by simp)

/--
A `fintype` with positive cardinality constructively contains an element.
-/
def trunc_of_card_pos {α} [fintype α] (h : 0 < fintype.card α) : trunc α :=
trunc_of_nonempty_fintype (fintype.card_pos_iff.mp h)

/--
By iterating over the elements of a fintype, we can lift an existential statement `∃ a, P a`
to `trunc (Σ' a, P a)`, containing data.
-/
def trunc_sigma_of_exists {α} [fintype α] {P : α → Prop} [decidable_pred P] (h : ∃ a, P a) :
  trunc (Σ' a, P a) :=
trunc_of_nonempty_fintype $ exists.elim h $ λ a ha, ⟨⟨a, ha⟩⟩

def biproduct.column_nonzero_of_iso
  {σ τ : Type v} [decidable_eq σ] [fintype σ] [decidable_eq τ] [fintype τ]
  {S : σ → C} [has_biproduct.{v} S] {T : τ → C} [has_biproduct.{v} T]
  (s : σ) (nz : 𝟙 (S s) ≠ 0)
  [∀ t, decidable_eq (S s ⟶ T t)]
  (f : ⨁ S ⟶ ⨁ T) [is_iso f] :
  trunc (Σ' t : τ, biproduct.ι S s ≫ f ≫ biproduct.π T t ≠ 0) :=
begin
  apply trunc_sigma_of_exists,
  -- Do this before we run `classical`, so we get the right `decidable_eq` instances.
  have t := biproduct.column_nonzero_of_iso'.{v} f s,
  classical,
  by_contradiction,
  simp only [classical.not_exists_not] at a,
  exact nz (t a)
end

end category_theory
