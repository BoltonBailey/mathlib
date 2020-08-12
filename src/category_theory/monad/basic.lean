/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Bhavik Mehta
-/
import category_theory.functor_category
import category_theory.concrete_category.bundled
import category_theory.monoidal.End
import category_theory.monoidal.internal

namespace category_theory
open category

universes v₁ u₁ -- declare the `v`'s first; see `category_theory.category` for an explanation

variables {C : Type u₁} [category.{v₁} C]

/--
The data of a monad on C consists of an endofunctor T together with natural transformations
η : 𝟭 C ⟶ T and μ : T ⋙ T ⟶ T satisfying three equations:
- T μ_X ≫ μ_X = μ_(TX) ≫ μ_X (associativity)
- η_(TX) ≫ μ_X = 1_X (left unit)
- Tη_X ≫ μ_X = 1_X (right unit)
-/
class monad (T : C ⥤ C) :=
(η [] : 𝟭 _ ⟶ T)
(μ [] : T ⋙ T ⟶ T)
(assoc' : ∀ X : C, T.map (nat_trans.app μ X) ≫ μ.app _ = μ.app (T.obj X) ≫ μ.app _ . obviously)
(left_unit' : ∀ X : C, η.app (T.obj X) ≫ μ.app _ = 𝟙 _  . obviously)
(right_unit' : ∀ X : C, T.map (η.app X) ≫ μ.app _ = 𝟙 _  . obviously)

variable (C)
/-- bundled monads. -/
structure Monad :=
(func : C ⥤ C)
(str : monad func . tactic.apply_instance)
variable {C}

restate_axiom monad.assoc'
restate_axiom monad.left_unit'
restate_axiom monad.right_unit'
attribute [simp] monad.left_unit monad.right_unit

notation `η_` := monad.η
notation `μ_` := monad.μ

/--
The data of a comonad on C consists of an endofunctor G together with natural transformations
ε : G ⟶ 𝟭 C and δ : G ⟶ G ⋙ G satisfying three equations:
- δ_X ≫ G δ_X = δ_X ≫ δ_(GX) (coassociativity)
- δ_X ≫ ε_(GX) = 1_X (left counit)
- δ_X ≫ G ε_X = 1_X (right counit)
-/
class comonad (G : C ⥤ C) :=
(ε [] : G ⟶ 𝟭 _)
(δ [] : G ⟶ (G ⋙ G))
(coassoc' : ∀ X : C, nat_trans.app δ _ ≫ G.map (δ.app X) = δ.app _ ≫ δ.app _ . obviously)
(left_counit' : ∀ X : C, δ.app X ≫ ε.app (G.obj X) = 𝟙 _ . obviously)
(right_counit' : ∀ X : C, δ.app X ≫ G.map (ε.app X) = 𝟙 _ . obviously)

variable (C)
/-- Bundled comonads. -/
structure CoMonad :=
(func : C ⥤ C)
(str : comonad func . tactic.apply_instance)
variable {C}

restate_axiom comonad.coassoc'
restate_axiom comonad.left_counit'
restate_axiom comonad.right_counit'
attribute [simp] comonad.left_counit comonad.right_counit

notation `ε_` := comonad.ε
notation `δ_` := comonad.δ

namespace monad
instance : monad (𝟭 C) :=
{ η := 𝟙 _,
  μ := 𝟙 _ }
/-- The initial monad. -/
def initial : Monad C := { func := 𝟭 _ }
instance unbundle_monad {M : Monad C} : monad M.func := M.str
instance : inhabited (Monad C) := ⟨initial⟩
end monad

namespace comonad
instance : comonad (𝟭 C) :=
{ ε := 𝟙 _,
  δ := 𝟙 _ }
/-- The terminal comonad. -/
def terminal : CoMonad C := { func := 𝟭 _ }
instance unbundle_comonad {M : CoMonad C} : comonad M.func := M.str
instance : inhabited (CoMonad C) := ⟨terminal⟩
end comonad

section unbundled_monads
variables {M : C ⥤ C} [monad M]
variables {N : C ⥤ C} [monad N]
variables {L : C ⥤ C} [monad L]
variables {K : C ⥤ C} [monad K]
/--
A morphism of monads is a natural transformation which is compatible with `η` and `μ`.
-/
variables (M N)
/-- A morphism of unbundled monads. -/
structure monad_hom extends nat_trans M N :=
(app_η' {X} : (η_ M).app X ≫ app X = (η_ N).app X . obviously)
(app_μ' {X} : (μ_ M).app X ≫ app X = (M.map (app X) ≫ app (N.obj X)) ≫ (μ_ N).app X . obviously)
attribute [nolint has_inhabited_instance] monad_hom
variables {M N}

restate_axiom monad_hom.app_η'
restate_axiom monad_hom.app_μ'

namespace monad
variable (M)
/--
The identity morphism on a monad `M`.
-/
def ident : monad_hom M M :=
{ app := λ X, 𝟙 _,
  app_η' := by simp,
  app_μ' := λ X, by {simp only [auto_param_eq, functor.map_id, comp_id], tidy} }
variable {M}
end monad

namespace monad_hom
@[ext]
theorem ext (f g : monad_hom M N) : f.to_nat_trans = g.to_nat_trans → f = g :=
  by {cases f, cases g, simp}

/--
The composition of morphisms of monads.
-/
def gg (f : monad_hom M N) (g : monad_hom N L) : monad_hom M L :=
{ app := λ X, (f.app X) ≫ (g.app X),
  app_η' := λ X, by {rw ←assoc, simp [app_η']},
  app_μ' := λ X, by {rw ←assoc, simp [app_μ']} }

@[simp] lemma ident_gg (f : monad_hom M N) : (monad.ident M).gg f = f := by {ext X, apply id_comp}
@[simp] lemma gg_ident (f : monad_hom M N) : f.gg (monad.ident N) = f := by {ext X, apply comp_id}

lemma gg_assoc (f : monad_hom M N) (g : monad_hom N L) (h : monad_hom L K) :
  (f.gg g).gg h = f.gg (g.gg h) := by {ext X, apply assoc}

end monad_hom
end unbundled_monads

section bundled_monads
variables {M : Monad C}
variables {N : Monad C}
variables {L : Monad C}
variables {K : Monad C}

variables (M N)
/-- Morphisms of bundled monads. -/
@[nolint has_inhabited_instance]
def Monad_hom := monad_hom M.func N.func
variables {M N}

instance : category (Monad C) :=
{ hom := Monad_hom,
  id := λ M, monad.ident _,
  comp := λ _ _ _, monad_hom.gg,
  id_comp' := λ _ _, by apply monad_hom.ident_gg,
  comp_id' := λ _ _, by apply monad_hom.gg_ident,
  assoc' := λ _ _ _ _, by apply monad_hom.gg_assoc }

local attribute [instance] endofunctor_monoidal_category

def monad_to_mon : Monad C → Mon_ (C ⥤ C) := λ M,
{ X := M.func,
  one := η_ _,
  mul := μ_ _,
  one_mul' := begin
    change (_ ◫ _) ≫ _ = _,
    ext A,
    simp only [nat_trans.hcomp_id_app, nat_trans.comp_app],
    apply monad.right_unit,
  end,
  mul_one' := begin
    change (_ ◫ _) ≫ _ = _,
    tidy,
  end,
  mul_assoc' := begin
    change (_ ◫ _) ≫ _ = _ ≫ (_ ◫ _) ≫ _,
    ext A,
    simp only [nat_trans.hcomp_id_app, nat_trans.hcomp_app, functor.map_id,
      nat_trans.id_app, comp_id, nat_trans.comp_app],
    erw id_comp,
    simp_rw monad.assoc,
    change _ = ((α_ M.func M.func M.func).app A).hom ≫ _ ≫ _,
    suffices : ((α_ M.func M.func M.func).app A).hom = 𝟙 _, by {rw this, simp},
    refl,
  end }

def to_mon_end : Monad C ⥤ Mon_ (C ⥤ C) :=
{ obj := monad_to_mon,
  map := λ M N f,
  { hom := f.to_nat_trans,
    one_hom' := begin
      ext,
      simp only [nat_trans.comp_app],
      apply f.app_η,
    end,
    mul_hom' := begin
      change _ = (_ ◫ _) ≫ _,
      ext,
      simp only [nat_trans.hcomp_app, assoc, nat_trans.comp_app],
      change (μ_ _).app x ≫ f.app x = _,
      rw f.app_μ,
      simp only [nat_trans.naturality, assoc],
      refl,
    end } }

def mon_to_monad : Mon_ (C ⥤ C) → Monad C := λ M,
{ func := M.X,
  str :=
  { η := M.one,
    μ := M.mul,
    assoc' := λ X, begin
      have := M.mul_assoc,
      rw ←nat_trans.hcomp_id_app,
      change ((M.mul ◫ 𝟙 M.X) ≫ M.mul).app X = _,
      erw this,
      simp only [nat_trans.comp_app],
      change ((α_ M.X M.X M.X).app X).hom ≫ (_ ◫ _).app X ≫ _ = _,
      suffices : ((α_ M.X M.X M.X).app X).hom = 𝟙 _, by {rw this, simp},
      refl,
    end,
    left_unit' := λ X, begin
      have := M.mul_one,
      change (_ ◫ _) ≫ _ = _ at this,
      rw [←nat_trans.id_hcomp_app, ←nat_trans.comp_app, this],
      refl,
    end,
    right_unit' := λ X, begin
      have := M.one_mul,
      change (_ ◫ _) ≫ _ = _ at this,
      rw [←nat_trans.hcomp_id_app, ←nat_trans.comp_app, this],
      refl,
    end } }

end bundled_monads

end category_theory
