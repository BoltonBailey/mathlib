/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import category_theory.epi_mono
import category_theory.limits.shapes.binary_products
import category_theory.preadditive
import algebra.big_operators

/-!
# Biproducts and binary biproducts

We introduce the notion of biproducts and binary biproducts.

These are slightly unusual relative to the other shapes in the library,
as they are simultaneously limits and colimits.
(Zero objects are similar; they are "biterminal".)

We treat first the case of a general category with zero morphisms,
and subsequently the case of a preadditive category.

In a category with zero morphisms, we model the (binary) biproduct of `P Q : C`
using a `binary_bicone`, which has a cone point `X`,
and morphisms `fst : X ⟶ P`, `snd : X ⟶ Q`, `inl : P ⟶ X` and `inr : X ⟶ Q`,
such that `inl ≫ fst = 𝟙 P`, `inl ≫ snd = 0`, `inr ≫ fst = 0`, and `inr ≫ snd = 𝟙 Q`.
Such a `binary_bicone` is a biproduct if the cone is a limit cone, and the cocone is a colimit cocone.

In a preadditive category, we prove the equivalence between three notions:
* a `binary_bicone` which satisfies `total : fst ≫ inl + snd ≫ inr = 𝟙 X`
* a `binary_bicone` whose cone is a limit cone,
* a `binary_bicone` whose cocone is a colimit cocone.

We use the first notion as the definition of a "preadditive biproduct".

For biproducts indexed by a `fintype J`, a `bicone` again consists of a cone point `X`
and morphisms `π j : X ⟶ F j` and `ι j : F j ⟶ X` for each `j`,
such that `ι j ≫ π j'` is the identity when `j = j'` and zero otherwise.

## Future work
Again, in a preadditive category we have a nice characterisation of when
a `bicone` indexed by a `fintype J` is a `biproduct`:
* `total : ∑ j, π j ≫ ι j = 𝟙 X`
and all the corresponding constructions for binary biproducts extend to this case.

## Notation
As `⊕` is already taken for the sum of types, we introduce the notation `X ⊞ Y` for
a binary biproduct. We introduce `⨁ f` for the indexed biproduct.
-/

universes v u

open category_theory
open category_theory.functor

namespace category_theory.limits

variables {J : Type v} [decidable_eq J]
variables {C : Type u} [category.{v} C] [has_zero_morphisms.{v} C]

/--
A `c : bicone F` is:
* an object `c.X` and
* morphisms `π j : X ⟶ F j` and `ι j : F j ⟶ X` for each `j`,
* such that `ι j ≫ π j'` is the identity when `j = j'` and zero otherwise.
-/
@[nolint has_inhabited_instance]
structure bicone (F : J → C) :=
(X : C)
(π : Π j, X ⟶ F j)
(ι : Π j, F j ⟶ X)
(ι_π : ∀ j j', ι j ≫ π j' = if h : j = j' then eq_to_hom (congr_arg F h) else 0)

@[simp] lemma bicone_ι_π_self {F : J → C} (B : bicone F) (j : J) : B.ι j ≫ B.π j = 𝟙 (F j) :=
by simpa using B.ι_π j j

@[simp] lemma bicone_ι_π_ne {F : J → C} (B : bicone F) {j j' : J} (h : j ≠ j') :
  B.ι j ≫ B.π j' = 0 :=
by simpa [h] using B.ι_π j j'

variables {F : J → C}

namespace bicone
/-- Extract the cone from a bicone. -/
@[simps]
def to_cone (B : bicone F) : cone (discrete.functor F) :=
{ X := B.X,
  π := { app := λ j, B.π j }, }
/-- Extract the cocone from a bicone. -/
@[simps]
def to_cocone (B : bicone F) : cocone (discrete.functor F) :=
{ X := B.X,
  ι := { app := λ j, B.ι j }, }
end bicone

/--
`has_biproduct F` represents a particular chosen bicone which is
simultaneously a limit and a colimit of the diagram `F`.
-/
class has_biproduct (F : J → C) :=
(bicone : bicone F)
(is_limit : is_limit bicone.to_cone)
(is_colimit : is_colimit bicone.to_cocone)

@[priority 100]
instance has_product_of_has_biproduct [has_biproduct F] : has_limit (discrete.functor F) :=
{ cone := has_biproduct.bicone.to_cone,
  is_limit := has_biproduct.is_limit, }

@[priority 100]
instance has_coproduct_of_has_biproduct [has_biproduct F] : has_colimit (discrete.functor F) :=
{ cocone := has_biproduct.bicone.to_cocone,
  is_colimit := has_biproduct.is_colimit, }

variables (J C)

/--
`C` has biproducts of shape `J` if we have chosen
a particular limit and a particular colimit, with the same cone points,
of every function `F : J → C`.
-/
class has_biproducts_of_shape :=
(has_biproduct : Π F : J → C, has_biproduct F)

attribute [instance, priority 100] has_biproducts_of_shape.has_biproduct

/-- `has_finite_biproducts C` represents a choice of biproduct for every family of objects in `C`
indexed by a finite type with decidable equality. -/
class has_finite_biproducts :=
(has_biproducts_of_shape : Π (J : Type v) [fintype J] [decidable_eq J],
  has_biproducts_of_shape.{v} J C)

attribute [instance, priority 100] has_finite_biproducts.has_biproducts_of_shape

variables {J C}

/--
The isomorphism between the specified limit and the specified colimit for
a functor with a bilimit.
-/
def biproduct_iso (F : J → C) [has_biproduct F] :
  limits.pi_obj F ≅ limits.sigma_obj F :=
eq_to_iso rfl

end category_theory.limits

namespace category_theory.limits
variables {J : Type v} [decidable_eq J]
variables {C : Type u} [category.{v} C] [has_zero_morphisms.{v} C]

/-- `biproduct f` computes the biproduct of a family of elements `f`. (It is defined as an
   abbreviation for `limit (discrete.functor f)`, so for most facts about `biproduct f`, you will
   just use general facts about limits and colimits.) -/
abbreviation biproduct (f : J → C) [has_biproduct f] :=
limit (discrete.functor f)

notation `⨁ ` f:20 := biproduct f

/-- The projection onto a summand of a biproduct. -/
abbreviation biproduct.π (f : J → C) [has_biproduct f] (b : J) : ⨁ f ⟶ f b :=
limit.π (discrete.functor f) b
/-- The inclusion into a summand of a biproduct. -/
abbreviation biproduct.ι (f : J → C) [has_biproduct f] (b : J) : f b ⟶ ⨁ f :=
colimit.ι (discrete.functor f) b

@[reassoc]
lemma biproduct.ι_π (f : J → C) [has_biproduct f] (j j' : J) :
  biproduct.ι f j ≫ biproduct.π f j' = if h : j = j' then eq_to_hom (congr_arg f h) else 0 :=
has_biproduct.bicone.ι_π j j'

/-- Given a collection of maps into the summands, we obtain a map into the biproduct. -/
abbreviation biproduct.lift
  {f : J → C} [has_biproduct f] {P : C} (p : Π b, P ⟶ f b) : P ⟶ ⨁ f :=
limit.lift _ (fan.mk p)
/-- Given a collection of maps out of the summands, we obtain a map out of the biproduct. -/
abbreviation biproduct.desc
  {f : J → C} [has_biproduct f] {P : C} (p : Π b, f b ⟶ P) : ⨁ f ⟶ P :=
colimit.desc _ (cofan.mk p)

/-- Given a collection of maps between corresponding summands of a pair of biproducts
indexed by the same type, we obtain a map between the biproducts. -/
abbreviation biproduct.map [fintype J] {f g : J → C} [has_finite_biproducts.{v} C]
  (p : Π b, f b ⟶ g b) : ⨁ f ⟶ ⨁ g :=
lim_map (discrete.nat_trans p)

/-- An alternative to `biproduct.map` constructed via colimits.
This construction only exists in order to show it is equal to `biproduct.map`. -/
abbreviation biproduct.map' [fintype J] {f g : J → C} [has_finite_biproducts.{v} C]
  (p : Π b, f b ⟶ g b) : ⨁ f ⟶ ⨁ g :=
@colim_map _ _ _ _ (discrete.functor f) (discrete.functor g) _ _ (discrete.nat_trans p)

@[ext] lemma biproduct.hom_ext [fintype J] {f : J → C} [has_finite_biproducts.{v} C]
  {Z : C} (g h : Z ⟶ ⨁ f)
  (w : ∀ j, g ≫ biproduct.π f j = h ≫ biproduct.π f j) : g = h :=
limit.hom_ext w

@[ext] lemma biproduct.hom_ext' [fintype J] {f : J → C} [has_finite_biproducts.{v} C]
  {Z : C} (g h : ⨁ f ⟶ Z)
  (w : ∀ j, biproduct.ι f j ≫ g =  biproduct.ι f j ≫ h) : g = h :=
colimit.hom_ext w

lemma biproduct.map_eq_map' [fintype J] {f g : J → C} [has_finite_biproducts.{v} C]
  (p : Π b, f b ⟶ g b) : biproduct.map p = biproduct.map' p :=
begin
  ext j j',
  simp only [discrete.nat_trans_app, limits.ι_colim_map, limits.lim_map_π, category.assoc],
  rw [biproduct.ι_π_assoc, biproduct.ι_π],
  split_ifs,
  { subst h, rw [eq_to_hom_refl, category.id_comp], erw category.comp_id, },
  { simp, },
end

instance biproduct.ι_mono (f : J → C) [has_biproduct f]
  (b : J) : split_mono (biproduct.ι f b) :=
{ retraction := biproduct.desc $
    λ b', if h : b' = b then eq_to_hom (congr_arg f h) else biproduct.ι f b' ≫ biproduct.π f b }

instance biproduct.π_epi (f : J → C) [has_biproduct f]
  (b : J) : split_epi (biproduct.π f b) :=
{ section_ := biproduct.lift $
    λ b', if h : b = b' then eq_to_hom (congr_arg f h) else biproduct.ι f b ≫ biproduct.π f b' }

-- Because `biproduct.map` is defined in terms of `lim` rather than `colim`,
-- we need to provide additional `simp` lemmas.
@[simp]
lemma biproduct.inl_map [fintype J] {f g : J → C} [has_finite_biproducts.{v} C]
  (p : Π j, f j ⟶ g j) (j : J) :
  biproduct.ι f j ≫ biproduct.map p = p j ≫ biproduct.ι g j :=
begin
  rw biproduct.map_eq_map',
  simp,
end

variables {C}

/--
A binary bicone for a pair of objects `P Q : C` consists of the cone point `X`,
maps from `X` to both `P` and `Q`, and maps from both `P` and `Q` to `X`,
so that `inl ≫ fst = 𝟙 P`, `inl ≫ snd = 0`, `inr ≫ fst = 0`, and `inr ≫ snd = 𝟙 Q`
-/
@[nolint has_inhabited_instance]
structure binary_bicone (P Q : C) :=
(X : C)
(fst : X ⟶ P)
(snd : X ⟶ Q)
(inl : P ⟶ X)
(inr : Q ⟶ X)
(inl_fst' : inl ≫ fst = 𝟙 P . obviously)
(inl_snd' : inl ≫ snd = 0 . obviously)
(inr_fst' : inr ≫ fst = 0 . obviously)
(inr_snd' : inr ≫ snd = 𝟙 Q . obviously)

restate_axiom binary_bicone.inl_fst'
restate_axiom binary_bicone.inl_snd'
restate_axiom binary_bicone.inr_fst'
restate_axiom binary_bicone.inr_snd'
attribute [simp, reassoc] binary_bicone.inl_fst binary_bicone.inl_snd
  binary_bicone.inr_fst binary_bicone.inr_snd

namespace binary_bicone
variables {P Q : C}

/-- Extract the cone from a binary bicone. -/
def to_cone (c : binary_bicone.{v} P Q) : cone (pair P Q) :=
binary_fan.mk c.fst c.snd

@[simp]
lemma to_cone_π_app_left (c : binary_bicone.{v} P Q) :
  c.to_cone.π.app (walking_pair.left) = c.fst := rfl
@[simp]
lemma to_cone_π_app_right (c : binary_bicone.{v} P Q) :
  c.to_cone.π.app (walking_pair.right) = c.snd := rfl

/-- Extract the cocone from a binary bicone. -/
def to_cocone (c : binary_bicone.{v} P Q) : cocone (pair P Q) :=
binary_cofan.mk c.inl c.inr

@[simp]
lemma to_cocone_ι_app_left (c : binary_bicone.{v} P Q) :
  c.to_cocone.ι.app (walking_pair.left) = c.inl := rfl
@[simp]
lemma to_cocone_ι_app_right (c : binary_bicone.{v} P Q) :
  c.to_cocone.ι.app (walking_pair.right) = c.inr := rfl

end binary_bicone

/--
`has_binary_biproduct P Q` represents a particular chosen bicone which is
simultaneously a limit and a colimit of the diagram `pair P Q`.
-/
class has_binary_biproduct (P Q : C) :=
(bicone : binary_bicone.{v} P Q)
(is_limit : is_limit bicone.to_cone)
(is_colimit : is_colimit bicone.to_cocone)

section
variable (C)

/--
`has_binary_biproducts C` represents a particular chosen bicone which is
simultaneously a limit and a colimit of the diagram `pair P Q`, for every `P Q : C`.
-/
class has_binary_biproducts :=
(has_binary_biproduct : Π (P Q : C), has_binary_biproduct.{v} P Q)

attribute [instance, priority 100] has_binary_biproducts.has_binary_biproduct

end

variables {P Q : C}

instance has_binary_biproduct.has_limit_pair [has_binary_biproduct.{v} P Q] :
  has_limit (pair P Q) :=
{ cone := has_binary_biproduct.bicone.to_cone,
  is_limit := has_binary_biproduct.is_limit.{v}, }

instance has_binary_biproduct.has_colimit_pair [has_binary_biproduct.{v} P Q] :
  has_colimit (pair P Q) :=
{ cocone := has_binary_biproduct.bicone.to_cocone,
  is_colimit := has_binary_biproduct.is_colimit.{v}, }

@[priority 100]
instance has_limits_of_shape_walking_pair [has_binary_biproducts.{v} C] :
  has_limits_of_shape.{v} (discrete walking_pair) C :=
{ has_limit := λ F, has_limit_of_iso (diagram_iso_pair F).symm }
@[priority 100]
instance has_colimits_of_shape_walking_pair [has_binary_biproducts.{v} C] :
  has_colimits_of_shape.{v} (discrete walking_pair) C :=
{ has_colimit := λ F, has_colimit_of_iso (diagram_iso_pair F) }

@[priority 100]
instance has_binary_products_of_has_binary_biproducts [has_binary_biproducts.{v} C] :
  has_binary_products.{v} C :=
⟨by apply_instance⟩

@[priority 100]
instance has_binary_coproducts_of_has_binary_biproducts [has_binary_biproducts.{v} C] :
  has_binary_coproducts.{v} C :=
⟨by apply_instance⟩

/--
The isomorphism between the specified binary product and the specified binary coproduct for
a pair for a binary biproduct.
-/
def biprod_iso (X Y : C) [has_binary_biproduct.{v} X Y]  :
  limits.prod X Y ≅ limits.coprod X Y :=
eq_to_iso rfl

/-- The chosen biproduct of a pair of objects. -/
abbreviation biprod (X Y : C) [has_binary_biproduct.{v} X Y] := limit (pair X Y)

notation X ` ⊞ `:20 Y:20 := biprod X Y

/-- The projection onto the first summand of a binary biproduct. -/
abbreviation biprod.fst {X Y : C} [has_binary_biproduct.{v} X Y] : X ⊞ Y ⟶ X :=
limit.π (pair X Y) walking_pair.left
/-- The projection onto the second summand of a binary biproduct. -/
abbreviation biprod.snd {X Y : C} [has_binary_biproduct.{v} X Y] : X ⊞ Y ⟶ Y :=
limit.π (pair X Y) walking_pair.right
/-- The inclusion into the first summand of a binary biproduct. -/
abbreviation biprod.inl {X Y : C} [has_binary_biproduct.{v} X Y] : X ⟶ X ⊞ Y :=
colimit.ι (pair X Y) walking_pair.left
/-- The inclusion into the second summand of a binary biproduct. -/
abbreviation biprod.inr {X Y : C} [has_binary_biproduct.{v} X Y] : Y ⟶ X ⊞ Y :=
colimit.ι (pair X Y) walking_pair.right

@[simp,reassoc]
lemma biprod.inl_fst {X Y : C} [has_binary_biproduct.{v} X Y] :
  (biprod.inl : X ⟶ X ⊞ Y) ≫ (biprod.fst : X ⊞ Y ⟶ X) = 𝟙 X :=
has_binary_biproduct.bicone.inl_fst
@[simp,reassoc]
lemma biprod.inl_snd {X Y : C} [has_binary_biproduct.{v} X Y] :
  (biprod.inl : X ⟶ X ⊞ Y) ≫ (biprod.snd : X ⊞ Y ⟶ Y) = 0 :=
has_binary_biproduct.bicone.inl_snd
@[simp,reassoc]
lemma biprod.inr_fst {X Y : C} [has_binary_biproduct.{v} X Y] :
  (biprod.inr : Y ⟶ X ⊞ Y) ≫ (biprod.fst : X ⊞ Y ⟶ X) = 0 :=
has_binary_biproduct.bicone.inr_fst
@[simp,reassoc]
lemma biprod.inr_snd {X Y : C} [has_binary_biproduct.{v} X Y] :
  (biprod.inr : Y ⟶ X ⊞ Y) ≫ (biprod.snd : X ⊞ Y ⟶ Y) = 𝟙 Y :=
has_binary_biproduct.bicone.inr_snd

/-- Given a pair of maps into the summands of a binary biproduct,
we obtain a map into the binary biproduct. -/
abbreviation biprod.lift {W X Y : C} [has_binary_biproduct.{v} X Y] (f : W ⟶ X) (g : W ⟶ Y) :
  W ⟶ X ⊞ Y :=
limit.lift _ (binary_fan.mk f g)
/-- Given a pair of maps out of the summands of a binary biproduct,
we obtain a map out of the binary biproduct. -/
abbreviation biprod.desc {W X Y : C} [has_binary_biproduct.{v} X Y] (f : X ⟶ W) (g : Y ⟶ W) :
  X ⊞ Y ⟶ W :=
colimit.desc _ (binary_cofan.mk f g)

/-- Given a pair of maps between the summands of a pair of binary biproducts,
we obtain a map between the binary biproducts. -/
abbreviation biprod.map {W X Y Z : C} [has_binary_biproduct.{v} W X] [has_binary_biproduct.{v} Y Z]
  (f : W ⟶ Y) (g : X ⟶ Z) : W ⊞ X ⟶ Y ⊞ Z :=
lim_map (@map_pair _ _ (pair W X) (pair Y Z) f g)

/-- An alternative to `biprod.map` constructed via colimits.
This construction only exists in order to show it is equal to `biprod.map`. -/
abbreviation biprod.map' {W X Y Z : C} [has_binary_biproduct.{v} W X] [has_binary_biproduct.{v} Y Z]
  (f : W ⟶ Y) (g : X ⟶ Z) : W ⊞ X ⟶ Y ⊞ Z :=
colim_map (@map_pair _ _ (pair W X) (pair Y Z) f g)

@[ext] lemma biprod.hom_ext {X Y Z : C} [has_binary_biproduct.{v} X Y] (f g : Z ⟶ X ⊞ Y)
  (h₀ : f ≫ biprod.fst = g ≫ biprod.fst) (h₁ : f ≫ biprod.snd = g ≫ biprod.snd) : f = g :=
binary_fan.is_limit.hom_ext has_binary_biproduct.is_limit h₀ h₁

@[ext] lemma biprod.hom_ext' {X Y Z : C} [has_binary_biproduct.{v} X Y] (f g : X ⊞ Y ⟶ Z)
  (h₀ : biprod.inl ≫ f = biprod.inl ≫ g) (h₁ : biprod.inr ≫ f = biprod.inr ≫ g) : f = g :=
binary_cofan.is_colimit.hom_ext has_binary_biproduct.is_colimit h₀ h₁

lemma biprod.map_eq_map' {W X Y Z : C} [has_binary_biproduct.{v} W X] [has_binary_biproduct.{v} Y Z]
  (f : W ⟶ Y) (g : X ⟶ Z) : biprod.map f g = biprod.map' f g :=
begin
  ext,
  { simp only [map_pair_left, ι_colim_map, lim_map_π, biprod.inl_fst_assoc, category.assoc],
    erw [biprod.inl_fst, category.comp_id], },
  { simp only [map_pair_left, ι_colim_map, lim_map_π, has_zero_morphisms.zero_comp,
      biprod.inl_snd_assoc, category.assoc],
    erw [biprod.inl_snd], simp, },
  { simp only [map_pair_right, biprod.inr_fst_assoc, ι_colim_map, lim_map_π,
      has_zero_morphisms.zero_comp, category.assoc],
    erw [biprod.inr_fst], simp, },
  { simp only [map_pair_right, ι_colim_map, lim_map_π, biprod.inr_snd_assoc, category.assoc],
    erw [biprod.inr_snd, category.comp_id], },
end

instance biprod.inl_mono {X Y : C} [has_binary_biproduct.{v} X Y] :
  split_mono (biprod.inl : X ⟶ X ⊞ Y) :=
{ retraction := biprod.desc (𝟙 X) (biprod.inr ≫ biprod.fst) }

instance biprod.inr_mono {X Y : C} [has_binary_biproduct.{v} X Y] :
  split_mono (biprod.inr : Y ⟶ X ⊞ Y) :=
{ retraction := biprod.desc (biprod.inl ≫ biprod.snd) (𝟙 Y)}

instance biprod.fst_epi {X Y : C} [has_binary_biproduct.{v} X Y] :
  split_epi (biprod.fst : X ⊞ Y ⟶ X) :=
{ section_ := biprod.lift (𝟙 X) (biprod.inl ≫ biprod.snd) }

instance biprod.snd_epi {X Y : C} [has_binary_biproduct.{v} X Y] :
  split_epi (biprod.snd : X ⊞ Y ⟶ Y) :=
{ section_ := biprod.lift (biprod.inr ≫ biprod.fst) (𝟙 Y) }

@[simp,reassoc]
lemma biprod.map_fst {W X Y Z : C} [has_binary_biproduct.{v} W X] [has_binary_biproduct.{v} Y Z]
  (f : W ⟶ Y) (g : X ⟶ Z) :
  biprod.map f g ≫ biprod.fst = biprod.fst ≫ f :=
by simp
@[simp,reassoc]
lemma biprod.map_snd {W X Y Z : C} [has_binary_biproduct.{v} W X] [has_binary_biproduct.{v} Y Z]
  (f : W ⟶ Y) (g : X ⟶ Z) :
  biprod.map f g ≫ biprod.snd = biprod.snd ≫ g :=
by simp

-- Because `biprod.map` is defined in terms of `lim` rather than `colim`,
-- we need to provide additional `simp` lemmas.
@[simp,reassoc]
lemma biprod.inl_map {W X Y Z : C} [has_binary_biproduct.{v} W X] [has_binary_biproduct.{v} Y Z]
  (f : W ⟶ Y) (g : X ⟶ Z) :
  biprod.inl ≫ biprod.map f g = f ≫ biprod.inl :=
begin
  rw biprod.map_eq_map',
  simp,
end
@[simp,reassoc]
lemma biprod.inr_map {W X Y Z : C} [has_binary_biproduct.{v} W X] [has_binary_biproduct.{v} Y Z]
  (f : W ⟶ Y) (g : X ⟶ Z) :
  biprod.inr ≫ biprod.map f g = g ≫ biprod.inr :=
begin
  rw biprod.map_eq_map',
  simp,
end

-- TODO:
-- If someone is interested, they could provide the constructions:
--   has_binary_biproducts ↔ has_finite_biproducts

end category_theory.limits

namespace category_theory.limits

section preadditive
variables {C : Type u} [category.{v} C] [preadditive.{v} C]
variables {J : Type v} [fintype J] [decidable_eq J]

open category_theory.preadditive
open_locale big_operators

/--
A preadditive binary product is a bicone on a family of objects `f : J → C` with `[fintype J]`
satisfying a further axiom
`total : ∑ j, π j ≫ ι j = 𝟙 _`.
The notion of preadditive binary product is strictly stronger than the notion of binary product
(but it in any preadditive category, the existence of a binary product implies the existence of a
preadditive binary product: a biproduct is, in particular, a (co)product,
and every (co)product gives rise to a preadditive biproduct).
-/
class has_preadditive_biproduct (f : J → C) :=
(bicone : bicone.{v} f)
(total' : ∑ j : J, bicone.π j ≫ bicone.ι j = 𝟙 bicone.X . obviously)

restate_axiom has_preadditive_biproduct.total'
attribute [simp] has_preadditive_biproduct.total

/-- A preadditive biproduct is a biproduct. -/
@[priority 100]
instance (f : J → C) [has_preadditive_biproduct.{v} f] : has_biproduct.{v} f :=
{ bicone := has_preadditive_biproduct.bicone,
  is_limit :=
  { lift := λ s, ∑ j, s.π.app j ≫ has_preadditive_biproduct.bicone.ι j,
    uniq' := λ s m h,
    begin
      erw [←category.comp_id m, ←has_preadditive_biproduct.total, comp_sum],
      apply finset.sum_congr rfl,
      intros j m,
      erw [reassoc_of (h j)],
    end,
    fac' := λ s j,
    begin
      simp [sum_comp],
      sorry,
    end },
  is_colimit :=
  { desc := λ s, ∑ j, has_preadditive_biproduct.bicone.π j ≫ s.ι.app j,
    uniq' := λ s m h,
    begin
      erw [←category.id_comp m, ←has_preadditive_biproduct.total, sum_comp],
            apply finset.sum_congr rfl,
      intros j m,
      erw [category.assoc, h],
    end,
    fac' := λ s j,
    begin
      simp,
      sorry,
    end } }

section
variables {f : J → C} [has_preadditive_biproduct.{v} f]

@[simp] lemma biproduct.total : ∑ j : J, biproduct.π f j ≫ biproduct.ι f j = 𝟙 (⨁ f) :=
has_preadditive_biproduct.total

lemma biproduct.lift_eq {T : C} {g : Π j, T ⟶ f j} :
  biproduct.lift g = ∑ j, g j ≫ biproduct.ι f j := rfl

lemma biproduct.desc_eq {T : C} {g : Π j, f j ⟶ T} :
  biproduct.desc g = ∑ j, biproduct.π f j ≫ g j := rfl

@[simp, reassoc] lemma biproduct.lift_desc {T U : C} {g : Π j, T ⟶ f j} {h : Π j, f j ⟶ U} :
  biproduct.lift g ≫ biproduct.desc h = ∑ j : J, g j ≫ h j :=
begin
  simp [biproduct.lift_eq, biproduct.desc_eq],
  sorry,
end

end

section has_product

/-- In a preadditive category, if the product over `f : J → C` exists, then the preadditive
    biproduct over `f` exists. -/
def has_preadditive_biproduct.of_has_product (f : J → C) [has_product.{v} f] :
  has_preadditive_biproduct.{v} f :=
{ bicone :=
  { X := pi_obj f,
    π := limits.pi.π f,
    ι := λ j, pi.lift (λ j', if h : j = j' then eq_to_hom (congr_arg f h) else 0),
    ι_π := sorry, },
  total' := sorry, }

/-- In a preadditive category, if the coproduct over `f : J → C` exists, then the preadditive
    biproduct over `f` exists. -/
def has_preadditive_biproduct.of_has_coproduct (f : J → C) [has_coproduct.{v} f] :
  has_preadditive_biproduct.{v} f :=
{ bicone :=
  { X := sigma_obj f,
    π := λ j, sigma.desc (λ j', if h : j' = j then eq_to_hom (congr_arg f h) else 0),
    ι := limits.sigma.ι f,
    ι_π := sorry, },
  total' := sorry, }

end has_product

section
variable (C)

/-- A preadditive category `has_preadditive_biproducts` if the preadditive biproduct
    exists for every pair of objects. -/
class has_preadditive_biproducts :=
(has_preadditive_biproduct : Π {J : Type v} [fintype J] [decidable_eq J] (f : J → C),
  has_preadditive_biproduct.{v} f)

attribute [instance, priority 100] has_preadditive_biproducts.has_preadditive_biproduct

@[priority 100]
instance [has_preadditive_biproducts.{v} C] : has_finite_biproducts.{v} C :=
⟨λ _ _ _, by apply_instance⟩

lemma comp_dite {P : Prop} [decidable P]
  {X Y Z : C} (f : X ⟶ Y) (g₀ : P → (Y ⟶ Z)) (g₁ : ¬P → (Y ⟶ Z)) :
  (f ≫ if h : P then g₀ h else g₁ h) = (if h : P then f ≫ g₀ h else f ≫ g₁ h) :=
by { split_ifs; refl }

lemma dite_comp {P : Prop} [decidable P]
  {X Y Z : C} (f₀ : P → (X ⟶ Y)) (f₁ : ¬P → (X ⟶ Y)) (g : Y ⟶ Z) :
  (if h : P then f₀ h else f₁ h) ≫ g = (if h : P then f₀ h ≫ g else f₁ h ≫ g) :=
by { split_ifs; refl }

lemma biproduct.map_eq [has_finite_biproducts.{v} C] {f g : J → C} {h : Π j, f j ⟶ g j} :
  biproduct.map h = ∑ j : J, biproduct.π f j ≫ h j ≫ biproduct.ι g j :=
begin
  apply biproduct.hom_ext,
  intro j,
  apply biproduct.hom_ext',
  intro j',
  simp [sum_comp, comp_sum, biproduct.ι_π, comp_dite],
end

/-- If a preadditive category has all products, then it has all preadditive biproducts. -/
def has_preadditive_biproducts_of_has_products [has_products.{v} C] :
  has_preadditive_biproducts.{v} C :=
⟨λ _ _ _ f, by exactI has_preadditive_biproduct.of_has_product f⟩

/-- If a preadditive category has all coproducts, then it has all preadditive biproducts. -/
def has_preadditive_biproducts_of_has_coproducts [has_coproducts.{v} C] :
  has_preadditive_biproducts.{v} C :=
⟨λ _ _ _ f, by exactI has_preadditive_biproduct.of_has_coproduct f⟩

end

/--
A preadditive binary biproduct is a bicone on two objects `X` and `Y` satisfying a further axiom
`total : fst ≫ inl + snd ≫ = 𝟙 _`.
The notion of preadditive binary biproduct is strictly stronger than the notion of binary biproduct
(but it in any preadditive category, the existence of a binary biproduct implies the existence of a
preadditive binary biproduct: a biproduct is, in particular, a (co)product,
and every (co)product gives rise to a preadditive binary biproduct,
see `has_preadditive_binary_biproduct.of_has_limit_pair`).
-/
class has_preadditive_binary_biproduct (X Y : C) :=
(bicone : binary_bicone.{v} X Y)
(total' : bicone.fst ≫ bicone.inl + bicone.snd ≫ bicone.inr = 𝟙 bicone.X . obviously)

restate_axiom has_preadditive_binary_biproduct.total'
attribute [simp] has_preadditive_binary_biproduct.total

/-- A preadditive binary biproduct is a binary biproduct. -/
@[priority 100]
instance (X Y : C) [has_preadditive_binary_biproduct.{v} X Y] : has_binary_biproduct.{v} X Y :=
{ bicone := has_preadditive_binary_biproduct.bicone,
  is_limit :=
  { lift := λ s, binary_fan.fst s ≫ has_preadditive_binary_biproduct.bicone.inl +
      binary_fan.snd s ≫ has_preadditive_binary_biproduct.bicone.inr,
    uniq' := λ s m h, by erw [←category.comp_id m, ←has_preadditive_binary_biproduct.total,
      comp_add, reassoc_of (h walking_pair.left), reassoc_of (h walking_pair.right)],
    fac' := λ s j, by cases j; simp, },
  is_colimit :=
  { desc := λ s, has_preadditive_binary_biproduct.bicone.fst ≫ binary_cofan.inl s +
      has_preadditive_binary_biproduct.bicone.snd ≫ binary_cofan.inr s,
    uniq' := λ s m h, by erw [←category.id_comp m, ←has_preadditive_binary_biproduct.total,
      add_comp, category.assoc, category.assoc, h walking_pair.left, h walking_pair.right],
    fac' := λ s j, by cases j; simp, } }

section
variables {X Y : C} [has_preadditive_binary_biproduct.{v} X Y]

@[simp] lemma biprod.total : biprod.fst ≫ biprod.inl + biprod.snd ≫ biprod.inr = 𝟙 (X ⊞ Y) :=
has_preadditive_binary_biproduct.total

lemma biprod.lift_eq {T : C} {f : T ⟶ X} {g : T ⟶ Y} :
  biprod.lift f g = f ≫ biprod.inl + g ≫ biprod.inr := rfl

lemma biprod.desc_eq {T : C} {f : X ⟶ T} {g : Y ⟶ T} :
  biprod.desc f g = biprod.fst ≫ f + biprod.snd ≫ g := rfl

@[simp, reassoc] lemma biprod.lift_desc {T U : C} {f : T ⟶ X} {g : T ⟶ Y} {h : X ⟶ U} {i : Y ⟶ U} :
  biprod.lift f g ≫ biprod.desc h i = f ≫ h + g ≫ i :=
by simp [biprod.lift_eq, biprod.desc_eq]

end

section has_limit_pair

/-- In a preadditive category, if the product of `X` and `Y` exists, then the preadditive binary
    biproduct of `X` and `Y` exists. -/
def has_preadditive_binary_biproduct.of_has_limit_pair (X Y : C) [has_limit.{v} (pair X Y)] :
  has_preadditive_binary_biproduct.{v} X Y :=
{ bicone :=
  { X := X ⨯ Y,
    fst := category_theory.limits.prod.fst,
    snd := category_theory.limits.prod.snd,
    inl := prod.lift (𝟙 X) 0,
    inr := prod.lift 0 (𝟙 Y) } }

/-- In a preadditive category, if the coproduct of `X` and `Y` exists, then the preadditive binary
    biproduct of `X` and `Y` exists. -/
def has_preadditive_binary_biproduct.of_has_colimit_pair (X Y : C) [has_colimit.{v} (pair X Y)] :
  has_preadditive_binary_biproduct.{v} X Y :=
{ bicone :=
  { X := X ⨿ Y,
    fst := coprod.desc (𝟙 X) 0,
    snd := coprod.desc 0 (𝟙 Y),
    inl := category_theory.limits.coprod.inl,
    inr := category_theory.limits.coprod.inr } }

end has_limit_pair

section
variable (C)

/-- A preadditive category `has_preadditive_binary_biproducts` if the preadditive binary biproduct
    exists for every pair of objects. -/
class has_preadditive_binary_biproducts :=
(has_preadditive_binary_biproduct : Π (X Y : C), has_preadditive_binary_biproduct.{v} X Y)

attribute [instance, priority 100] has_preadditive_binary_biproducts.has_preadditive_binary_biproduct

@[priority 100]
instance [has_preadditive_binary_biproducts.{v} C] : has_binary_biproducts.{v} C :=
⟨λ X Y, by apply_instance⟩

lemma biprod.map_eq [has_binary_biproducts.{v} C] {W X Y Z : C} {f : W ⟶ Y} {g : X ⟶ Z} :
  biprod.map f g = biprod.fst ≫ f ≫ biprod.inl + biprod.snd ≫ g ≫ biprod.inr :=
by apply biprod.hom_ext; apply biprod.hom_ext'; simp

/-- If a preadditive category has all binary products, then it has all preadditive binary
    biproducts. -/
def has_preadditive_binary_biproducts_of_has_binary_products [has_binary_products.{v} C] :
  has_preadditive_binary_biproducts.{v} C :=
⟨λ X Y, has_preadditive_binary_biproduct.of_has_limit_pair X Y⟩

/-- If a preadditive category has all binary coproducts, then it has all preadditive binary
    biproducts. -/
def has_preadditive_binary_biproducts_of_has_binary_coproducts [has_binary_coproducts.{v} C] :
  has_preadditive_binary_biproducts.{v} C :=
⟨λ X Y, has_preadditive_binary_biproduct.of_has_colimit_pair X Y⟩

end

end preadditive

end category_theory.limits
