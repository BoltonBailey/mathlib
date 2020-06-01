/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import category_theory.comma
import category_theory.groupoid

/-!
# The category of elements

This file defines the category of elements, also known as (a special case of) the Grothendieck construction.

Given a functor `F : C ⥤ Type`, an object of `F.elements` is a pair `(X : C, x : F.obj X)`.
A morphism `(X, x) ⟶ (Y, y)` is a morphism `f : X ⟶ Y` in `C`, so `F.map f` takes `x` to `y`.

## Implementation notes
This construction is equivalent to a special case of a comma construction, so this is mostly just
a more convenient API. We prove the equivalence in `category_theory.category_of_elements.comma_equivalence`.

## References
* [Emily Riehl, *Category Theory in Context*, Section 2.4][riehl2017]
* <https://en.wikipedia.org/wiki/Category_of_elements>
* <https://ncatlab.org/nlab/show/category+of+elements>

## Tags
category of elements, Grothendieck construction, comma category
-/

namespace category_theory

universes w v u
variables {C : Type u} [𝒞 : category.{v} C]
include 𝒞

/-- The type of objects for the category of elements of a functor `F : C ⥤ Type` is a pair `(X : C, x : F.obj X)`. -/
def functor.elements (F : C ⥤ Type w) : Type (max u w) := (Σ c : C, F.obj c)

/-- The category structure on `F.elements`, for `F : C ⥤ Type`.
    A morphism `(X, x) ⟶ (Y, y)` is a morphism `f : X ⟶ Y` in `C`, so `F.map f` takes `x` to `y`.
 -/
instance category_of_elements (F : C ⥤ Type w) : category.{v} F.elements :=
{ hom := λ p q, { f : p.1 ⟶ q.1 // (F.map f) p.2 = q.2 },
  id := λ p, ⟨𝟙 p.1, by obviously⟩,
  comp := λ p q r f g, ⟨f.val ≫ g.val, by obviously⟩ }

namespace category_of_elements
variables {F : C ⥤ Type w}

@[simp] lemma condition {X Y : F.elements} (f : X ⟶ Y) : F.map f.1 X.2 = Y.2 := f.2

@[ext]
lemma ext {x y : F.elements} (f g : x ⟶ y) (w : f.val = g.val) : f = g :=
subtype.eq' w

@[simp] lemma comp_val {p q r : F.elements} {f : p ⟶ q} {g : q ⟶ r} :
  (f ≫ g).val = f.val ≫ g.val := rfl

@[simp] lemma id_val {p : F.elements} : (𝟙 p : p ⟶ p).val = 𝟙 p.1 := rfl

end category_of_elements

section
variables {F : C ⥤ Type w}

def as_element {X : C} (x : F.obj X) : F.elements := ⟨X, x⟩

@[simp] lemma as_element_fst {X : C} (x : F.obj X) : (as_element x).1 = X := rfl
@[simp] lemma as_element_snd {X : C} (x : F.obj X) : (as_element x).2 = x := rfl

def as_element_hom_of_eq {X Y : C} (f : X ⟶ Y) (x : F.obj X) (y : F.obj Y) (h : F.map f x = y) :
  as_element x ⟶ as_element y :=
{ val := f, property := h }

@[simp] lemma as_element_hom_of_eq_val {X Y : C} (f : X ⟶ Y) (x : F.obj X) (y : F.obj Y) (h : F.map f x = y) :
  (as_element_hom_of_eq f x y h).val = f := rfl

@[simp] lemma as_element_hom_of_eq_comp {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z)
  (x : F.obj X) (y : F.obj Y) (z : F.obj Z) (h₁ : F.map f x = y) (h₂ : F.map g y = z) :
  as_element_hom_of_eq f x y h₁ ≫ as_element_hom_of_eq g y z h₂ =
    as_element_hom_of_eq (f ≫ g) x z (by { rw [←h₂, ←h₁], simp }) :=
rfl

@[reducible]
def as_element_hom {X Y : C} (f : X ⟶ Y) (x : F.obj X) :
  as_element x ⟶ as_element (F.map f x) :=
as_element_hom_of_eq f x _ rfl

def as_element_iso {X Y : C} (f : X ≅ Y) (x : F.obj X) :
  as_element x ≅ as_element (F.map f.hom x) :=
{ hom := as_element_hom f.hom x,
  inv := as_element_hom_of_eq f.inv (F.map f.hom x) _ (by simp) }

end

omit 𝒞 -- We'll assume C has a groupoid structure, so temporarily forget its category structure
-- to avoid conflicts.
instance groupoid_of_elements [groupoid C] (F : C ⥤ Type w) : groupoid F.elements :=
{ inv := λ p q f, ⟨inv f.val,
      calc F.map (inv f.val) q.2 = F.map (inv f.val) (F.map f.val p.2) : by rw f.2
                             ... = (F.map f.val ≫ F.map (inv f.val)) p.2 : by simp
                             ... = p.2 : by {rw ←functor.map_comp, simp}⟩ }
include 𝒞

namespace category_of_elements
variable (F : C ⥤ Type w)

/-- The functor out of the category of elements which forgets the element. -/
def π : F.elements ⥤ C :=
{ obj := λ X, X.1,
  map := λ X Y f, f.val }

@[simp] lemma π_obj (X : F.elements) : (π F).obj X = X.1 := rfl
@[simp] lemma π_map {X Y : F.elements} (f : X ⟶ Y) : (π F).map f = f.val := rfl

/-- The forward direction of the equivalence `F.elements ≅ (*, F)`. -/
def to_comma : F.elements ⥤ comma ((functor.const punit).obj punit) F :=
{ obj := λ X, { left := punit.star, right := X.1, hom := λ _, X.2 },
  map := λ X Y f, { right := f.val } }

@[simp] lemma to_comma_obj (X) :
  (to_comma F).obj X = { left := punit.star, right := X.1, hom := λ _, X.2 } := rfl
@[simp] lemma to_comma_map {X Y} (f : X ⟶ Y) :
  (to_comma F).map f = { right := f.val } := rfl

/-- The reverse direction of the equivalence `F.elements ≅ (*, F)`. -/
def from_comma : comma ((functor.const punit).obj punit) F ⥤ F.elements :=
{ obj := λ X, ⟨X.right, X.hom (punit.star)⟩,
  map := λ X Y f, ⟨f.right, congr_fun f.w'.symm punit.star⟩ }

@[simp] lemma from_comma_obj (X) :
  (from_comma F).obj X = ⟨X.right, X.hom (punit.star)⟩ := rfl
@[simp] lemma from_comma_map {X Y} (f : X ⟶ Y) :
  (from_comma F).map f = ⟨f.right, congr_fun f.w'.symm punit.star⟩ := rfl

/-- The equivalence between the category of elements `F.elements`
    and the comma category `(*, F)`. -/
def comma_equivalence : F.elements ≌ comma ((functor.const punit).obj punit) F :=
equivalence.mk (to_comma F) (from_comma F)
  (nat_iso.of_components (λ X, eq_to_iso (by tidy)) (by tidy))
  (nat_iso.of_components
    (λ X, { hom := { right := 𝟙 _ }, inv := { right := 𝟙 _ } })
    (by tidy))

end category_of_elements
end category_theory
