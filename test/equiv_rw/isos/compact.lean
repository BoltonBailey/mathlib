import topology.category.Top.basic
import category_theory.hygienic
import control.equiv_functor
import tactic.equiv_rw
import category_theory.functorial
import category_theory.elements
import .set
-- import topology.subset_properties


open set filter classical category_theory
open_locale classical topological_space

def cpct (X : Top) : Prop :=
∀ (f : filter X), f ≠ ⊥ → ∃ (x : X), f ⊓ 𝓝 x ≠ ⊥

section

universes u v w
variables {C : Type u} [category.{v} C]

class hygienic_relative (F : C → Type w) [iso_functorial.{v w} F] (P : Π X, F X → Prop) :=
(map : ∀ {X Y : C} (i : X ≅ Y) (y : F Y), P X (((iso_functorial.map.{v w} F i.symm) : F Y → F X) y) → P Y y)

def hygienic_relative.map' {F : C → Type w} [iso_functorial.{v w} F]
  {P : Π X, F X → Prop} [hygienic_relative F P] {X Y : C} (i : X ≅ Y) (x : F X) (w : P X x) :
  P Y (((iso_functorial.map.{v w} F i) : F X → F Y) x) :=
begin
  have t : x = ((iso_functorial.map.{v w} F i.symm : F Y → F X) (((iso_functorial.map.{v w} F i) : F X → F Y) x)),
  { change x = ((iso_functorial.map.{v w} F i) ≫ (iso_functorial.map.{v w} F i.symm)) x,
    rw ←iso_functorial.map_comp,
    simp, },
  rw t at w,
  apply hygienic_relative.map i _ w,
end

-- def bundle_relative (F : C → Type w) [iso_functorial.{v w} F] (P : Π X, F X → Prop) :
--   (functor.of_iso_functorial F).elements → Prop :=
-- λ X, P (core.desc X.1) X.2

def hygienic_relative.of_hygienic_elements
  (F : C → Type w) [iso_functorial.{v w} F] (P : Π X, F X → Prop)
  [I : hygienic.{v} (λ X : (functor.of_iso_functorial F).elements, P (core.desc X.1) X.2)] :
  hygienic_relative F P :=
{ map := λ X Y i y w,
  begin
    let y' : (functor.of_iso_functorial F).obj (core.lift Y) := y,
    let i' := (as_element_iso (core.lift_iso_to_iso i.symm) y').symm,
    refine @hygienic.map _ _ _ I _ _ i' w,
  end }

def hygienic_relative.implies (F : C → Type w) [iso_functorial.{v w} F]
  (P Q : Π X, F X → Prop) [hygienic_relative F P] [hygienic_relative F Q] :
  hygienic_relative F (λ X x, P X x → Q X x) :=
{ map := λ X Y i y h w, hygienic_relative.map i _ (h (hygienic_relative.map' i.symm _ w)), }

end

universes u v w
variables {C : Type u} [category.{v} C]

def hygienic_forall (F : C → Type w) [iso_functorial.{v w} F] (
  P : Π X, F X → Prop) [hygienic_relative.{u v w} F P] :
  hygienic.{v} (λ X, ∀ (x : F X), P X x) :=
{ map := λ X Y i h x, hygienic_relative.map.{u v w} i _ (h _), }

def hygienic_exists (F : C → Type w) [iso_functorial.{v w} F] (
  P : Π X, F X → Prop) [hygienic_relative.{u v w} F P] :
  hygienic.{v} (λ X, ∃ (x : F X), P X x) :=
{ map := λ X Y i ⟨x, w⟩,
  ⟨(iso_functorial.map.{v w u} F i : F X → F Y) x, hygienic_relative.map' _ _ w⟩, }

def hygienic_eq (F : C → Type w) [iso_functorial.{v w} F]
  (L R : Π X, F X) [flat_section'.{u v w} L] [flat_section'.{u v w} R] :
  hygienic.{v} (λ X, L X = R X) :=
{ map := λ X Y i h, by rw [←flat_section'.transport L i, ←flat_section'.transport R i, ←h], }

instance iso_functorial_elements_1 (F : C ⥤ Type w) : iso_functorial.{v w} (λ X : F.elements, F.obj X.1) :=
{ map := λ X Y i, F.map i.hom.1, }.

def flat_section_elements_2 (F : C ⥤ Type w) :
  flat_section'.{(max u w) v w} (λ X : F.elements, X.2) :=
{ transport := λ X Y i, by simp [iso_functorial.map], }

instance : hygienic.{v} cpct.{v} :=
begin
  apply @hygienic_forall _ _ _ _ _ _,
  { -- should be easy
    sorry, },
  { apply @hygienic_relative.implies _ _ _ _ _ _ _ _,
    { apply @hygienic_relative.of_hygienic_elements _ _ _ _ _ _,
      apply @hygienic_not _ _ _ _,
      apply @hygienic_eq _ _ _ _ _ _ _ _,
      { apply iso_functorial_elements_1, },
      { apply flat_section_elements_2, },
      { -- This is interesting. We need to notice that the value doesn't depend on the element.
        split, intros, dsimp, sorry, }, },
    { apply @hygienic_relative.of_hygienic_elements _ _ _ _ _ _,
      apply @hygienic_exists _ _ _ _ _ _,
      { sorry, },
      { apply @hygienic_relative.of_hygienic_elements _ _ _ _ _ _,
        apply @hygienic_not _ _ _ _,
        apply @hygienic_eq _ _ _ _ _ _ _ _,
        { sorry, },
        { sorry, },
        { sorry, }, } } },

end
