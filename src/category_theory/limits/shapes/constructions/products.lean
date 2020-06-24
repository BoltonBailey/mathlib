/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import category_theory.limits.shapes.biproducts
import tactic.equiv_rw

/-!
We construct isomorphisms describing products over certain shapes.

* Products over sigma types:
```
def product_over_sigma_iso {I : Type v} {Z : I → Type v} (f : (Σ i, Z i) → C) :
  ∏ f ≅ ∏ λ i, ∏ (λ z, f ⟨i, z⟩)
```
* Products over two element types as binary products:
```
def product_over_equiv_walking_pair {I : Type v} (e : I ≃ walking_pair) (f : I → C)
  ∏ f ≅ (f (e.symm left)) ⨯ (f (e.symm right))
```
* Products over one element types:
```
def product_over_equiv_punit {I : Type v} (e : I ≃ punit) (f : I → C) :
  ∏ f ≅ f (e.symm punit.star)
```
* Products over `sum` types:
```
def product_over_sum_iso {I J : Type v} (f : I ⊕ J → C) :
  ∏ f ≅ (∏ f ∘ sum.inl) ⨯ (∏ f ∘ sum.inr)
```

### TODO
* Also the coproduct and biproduct versions of these.

* These isomorphisms could be further generalized to limits over disjoint union diagrams.
  (One could even do diagrams of the form `Σ i, Z i`,
  although one would first have to set up the category structure.)
-/

universes v u

open category_theory

namespace category_theory.limits

variables {C : Type u} [category.{v} C]

/--
We can restrict a cone over a sigma type to a cone over one of the fibers.
-/
@[simps]
def fan.restrict_to_fiber {I : Type v} {Z : I → Type v} {f : (Σ i, Z i) → C}
  (c : fan f) (i : I) : fan (λ z, f ⟨i, z⟩) :=
{ X := c.X,
  π := { app := λ z, c.π.app ⟨i, z⟩, }, }

/--
Given a cone over each fiber of a sigma type,
and then a cone over the cone points of those cones,
we can build a cone over the sigma type.
-/
@[simps]
def cone_over_sigma {I : Type v} {Z : I → Type v} (f : (Σ i, Z i) → C)
  (P : Π i, fan (λ z, f ⟨i, z⟩)) (Q : fan (λ i, (P i).X)) :
  fan f :=
{ X := Q.X,
  π :=
  { app := λ p, Q.π.app p.1 ≫ (P p.1).π.app p.2 ≫ eq_to_hom (by { cases p, refl, }),
    naturality' := λ X Y f,
    begin
      cases X with Xi Xz, cases Y with Yi Yz, rcases f with ⟨⟨⟨rfl, rfl⟩⟩⟩,
      simp,
    end, }, }

/--
Given a cone `s` over a sigma type, and limit cones `P i` over each fiber,
we can lift `s` to produce a cone over the limit points `(P i).X`.
-/
@[simps]
def lift_over_fibers {I : Type v} {Z : I → Type v} {f : (Σ i, Z i) → C}
  (P : Π i, fan (λ z, f ⟨i, z⟩))
  (w : Π i, is_limit (P i)) (s : fan f) :
  fan (λ i, (P i).X) :=
{ X := s.X,
  π := { app := λ i, (w i).lift (s.restrict_to_fiber i) }, }

/--
When all of the cones used in `cone_over_sigma f P Q` are limit cones,
the resulting cone is also a limit cone.
-/
def is_limit_cone_over_sigma {I : Type v} {Z : I → Type v} (f : (Σ i, Z i) → C)
  (P : Π i, fan (λ z, f ⟨i, z⟩)) (Q : fan (λ i, (P i).X))
  (w₁ : Π i, is_limit (P i)) (w₂ : is_limit Q) :
  is_limit (cone_over_sigma f P Q) :=
{ lift := λ s, w₂.lift
  { X := s.X,
    π := { app := λ i, (w₁ i).lift (fan.restrict_to_fiber s i), }, },
  uniq' := λ s m w,
  begin
    apply w₂.uniq (lift_over_fibers P w₁ s) m,
    intro i,
    apply (w₁ i).hom_ext,
    intro z,
    simpa using w ⟨i, z⟩,
  end, }

/--
Given any specified choices of the products involved (via `has_*` instances),
the product over a sigma type is isomorphic to
the product over the base of the products over the fibers.
-/
def product_over_sigma_iso {I : Type v} {Z : I → Type v} (f : (Σ i, Z i) → C)
  [has_product f] [∀ i, has_product (λ z, f ⟨i, z⟩)] [has_product (λ i, ∏ (λ z, f ⟨i, z⟩))] :
  ∏ f ≅ ∏ λ i, ∏ (λ z, f ⟨i, z⟩) :=
begin
  transitivity (cone_over_sigma f (λ i, limit.cone (discrete.functor (λ z, f ⟨i, z⟩))) _).X,
  { apply is_limit.cone_point_unique_up_to_iso (limit.is_limit _)
    (is_limit_cone_over_sigma _ _ _ _ _),
    { exact (λ i, limit.is_limit _), },
    { apply limit.is_limit _, assumption, } },
  { simp,
    apply iso.refl, },
end

section
open walking_pair

lemma equiv_walking_pair_aux {I : Type v} (e : I ≃ limits.walking_pair) (f : I → C) (i : I) :
  (limits.pair (f (e.symm left)) (f (e.symm right))).obj (e i) =
    (discrete.functor f).obj i :=
begin
  cases h : e i;
  { simp only [discrete.functor_obj, limits.pair_obj_left, limits.pair_obj_right],
    rw [←h, equiv.symm_apply_apply], }
end

local attribute [simp] equiv_walking_pair_aux

/--
Given an equivalence `I ≃ walking_pair`, we can convert a `binary_fan` to a `fan`.
-/
@[simps]
def fan_of_binary_fan {I : Type v} (e : I ≃ walking_pair) {f : I → C}
  (c : binary_fan (f (e.symm left)) (f (e.symm right))) : fan f :=
{ X := c.X,
  π := { app := λ i, c.π.app (e i) ≫ eq_to_hom (by simp), }, }

/--
Given an equivalence `I ≃ walking_pair`,
we get an equivalence of categories of cones,
allowing us to convert between `fan` and `binary_fan`.
-/
def cone_equivalence_of_equiv_walking_pair {I : Type v} (e : I ≃ walking_pair) (f : I → C) :
  cone (discrete.functor f) ≌ cone (pair (f (e.symm left)) (f (e.symm right))) :=
begin
  apply cones.equivalence_of_reindexing (discrete.equivalence e.symm),
  apply discrete.nat_iso,
  rintro ⟨i|j⟩; simp,
end

/--
If a fan over a type equivalent to `walking_pair` is a limit cone,
then the corresponding binary fan is a limit cone too.
-/
def is_limit_binary_fan_of_is_limit_fan {I : Type v} (e : I ≃ walking_pair) (f : I → C)
  (c : fan f) (h : is_limit c) :
  is_limit ((cone_equivalence_of_equiv_walking_pair e f).functor.obj c) :=
is_limit.of_cone_equiv _ h

/--
If a binary_fan is a limit cone,
then the corresponding fan over a type equivalent to `walking_pair` is a limit cone too.
-/
def is_limit_fan_of_is_limit_binary_fan {I : Type v} (e : I ≃ walking_pair) (f : I → C)
  (c : binary_fan (f (e.symm left)) (f (e.symm right))) (h : is_limit c) :
  is_limit ((cone_equivalence_of_equiv_walking_pair e f).inverse.obj c) :=
is_limit.of_cone_equiv _ h

/--
Given any specified choice of the product,
the product over a type equivalent to `walking_pair`
is just the binary product of the two objects.
-/
-- We could prove this using the above lemmas tranferring `is_limit` terms,
-- but there is also a direct API for comparing chosen limits.
def product_over_equiv_walking_pair {I : Type v} (e : I ≃ walking_pair) (f : I → C)
  [has_product f] [has_binary_product (f (e.symm left)) (f (e.symm right))] :
  ∏ f ≅ (f (e.symm left)) ⨯ (f (e.symm right)) :=
has_limit.ext_of_equivalence (discrete.equivalence e) (discrete.nat_iso (λ i, by simp))

end

/--
Given any specified choice of the product,
the product over a type equivalent to `punit`
is just the object sitting over `punit.star`.
-/
@[simps]
def product_over_equiv_punit_iso {I : Type v} (e : I ≃ punit) (f : I → C) [has_product f] :
  ∏ f ≅ f (e.symm punit.star) :=
{ hom := pi.π f (e.symm punit.star),
  inv := pi.lift (λ i, eq_to_hom (congr_arg f (e.injective (subsingleton.elim _ _)))),
  hom_inv_id' := begin ext j, equiv_rw e at j, cases j, simp, end, }

/--
Given any specified choice of the product,
the product over a `unique` type `I`
is just the object sitting over `default I`.
-/
def product_over_unique_iso {I : Type v} [unique I] (f : I → C) [has_product f] :
  ∏ f ≅ f (default I) :=
product_over_equiv_punit_iso equiv_punit_of_unique f

@[simp] lemma product_over_unique_iso_hom {I : Type v} [unique I] (f : I → C) [has_product f] :
  (product_over_unique_iso f).hom = pi.π f (default I) :=
rfl

/--
Given any specified choice of the coproduct,
the coproduct over a type equivalent to `punit`
is just the object sitting over `punit.star`.
-/
@[simps]
def coproduct_over_equiv_punit_iso {I : Type v} (e : I ≃ punit) (f : I → C) [has_coproduct f] :
  ∐ f ≅ f (e.symm punit.star) :=
{ hom := sigma.desc (λ i, eq_to_hom (congr_arg f (e.injective (subsingleton.elim _ _)))),
  inv := sigma.ι f (e.symm punit.star),
  hom_inv_id' := begin ext j, equiv_rw e at j, cases j, simp, dsimp, simp, end, }

/--
Given any specified choice of the coproduct,
the coproduct over a `unique` type `I`
is just the object sitting over `default I`.
-/
def coproduct_over_unique_iso {I : Type v} [unique I] (f : I → C) [has_coproduct f] :
  ∐ f ≅ f (default I) :=
coproduct_over_equiv_punit_iso equiv_punit_of_unique f

@[simp] lemma coproduct_over_unique_iso_inv {I : Type v} [unique I] (f : I → C) [has_coproduct f] :
  (coproduct_over_unique_iso f).inv = sigma.ι f (default I) :=
rfl

section
variables [has_zero_morphisms.{v} C]

lemma product_over_unique_iso_eq_coproduct_over_unique_iso
  {I : Type v} [unique I]
  (f : I → C) [has_biproduct.{v} f] :
  product_over_unique_iso f = coproduct_over_unique_iso f :=
begin
  ext1,
  apply (cancel_epi (coproduct_over_unique_iso f).inv).1,
  rw [(coproduct_over_unique_iso f).inv_hom_id],
  simp,
end

@[simp]
lemma product_over_unique_iso_inv
  {I : Type v} [unique I]
  (f : I → C) [has_biproduct.{v} f] :
  (product_over_unique_iso f).inv = sigma.ι f (default I) :=
begin
  rw product_over_unique_iso_eq_coproduct_over_unique_iso,
  simp,
end

@[simp]
lemma coproduct_over_unique_iso_hom
  {I : Type v} [unique I]
  (f : I → C) [has_biproduct.{v} f] :
  (coproduct_over_unique_iso f).hom = pi.π f (default I) :=
begin
  rw ←product_over_unique_iso_eq_coproduct_over_unique_iso,
  simp,
end

end

/--
Given any specified choices of the products involved (using `has_*` typeclasses),
the product over a `sum` type is isomorphic to
the binary product of the products over the two types.
-/
-- We could muck about transferring `is_limit` instances,
-- but it's so easy to just write down the maps,
-- and let automation apply the extensionality lemmas to prove they are inverses.
@[simps] -- TODO perhaps provide the simp lemma only for `hom` here, and a (nicer) simp lemma for `inv` in the presence of biproducts?
def product_over_sum_iso {I J : Type v} (f : I ⊕ J → C)
  [has_product f] [has_product (f ∘ sum.inl)] [has_product (f ∘ sum.inr)]
  [has_binary_product (∏ f ∘ sum.inl) (∏ f ∘ sum.inr)] :
  ∏ f ≅ (∏ f ∘ sum.inl) ⨯ (∏ f ∘ sum.inr) :=
{ hom := prod.lift (pi.lift (λ i, pi.π f (sum.inl i))) (pi.lift (λ j, pi.π f (sum.inr j))),
  inv := pi.lift (λ x, sum.cases_on x
    (λ (i : I), limits.prod.fst ≫ limits.pi.π _ i)
    (λ (j : J), limits.prod.snd ≫ limits.pi.π _ j)), }

/--
Given any specified choices of the coproducts involved (using `has_*` typeclasses),
the coproduct over a `sum` type is isomorphic to
the binary coproduct of the coproducts over the two types.
-/
@[simps]
def coproduct_over_sum_iso {I J : Type v} (f : I ⊕ J → C)
  [has_coproduct f] [has_coproduct (f ∘ sum.inl)] [has_coproduct (f ∘ sum.inr)]
  [has_binary_coproduct (∐ f ∘ sum.inl) (∐ f ∘ sum.inr)] :
  ∐ f ≅ (∐ f ∘ sum.inl) ⨿ (∐ f ∘ sum.inr) :=
{ hom := sigma.desc (λ x, sum.cases_on x
    (λ (i : I), @sigma.ι I _ _ (λ i : I, f (sum.inl i)) _ i ≫ coprod.inl)
    (λ (j : J), @sigma.ι J _ _ (λ j : J, f (sum.inr j)) _ j ≫ coprod.inr)),
  inv := coprod.desc (sigma.desc (λ i, sigma.ι f (sum.inl i))) (sigma.desc (λ j, sigma.ι f (sum.inr j))), }

/--
Given any specified choices of the products involved (using `has_*` typeclasses),
the product over a `sum` type is isomorphic to
the binary product of the products over the two types.

This variant of `product_over_sum_iso` is expressed in terms of two functions,
one out of each of the two types.
-/
def product_over_sum_iso' {I J : Type v} (f : I → C) (g : J → C)
  [has_product f] [has_product g] [has_product (sum.elim f g)] [has_binary_product (∏ f) (∏ g)] :
  ∏ (sum.elim f g) ≅ ∏ f ⨯ ∏ g :=
product_over_sum_iso (sum.elim f g)

-- TODO simp lemma for this

/-- TODO explain why we need this! -/
def congr_eq_to_hom {I : Type v} (f : I → C) {i i' : I} (h : i = i') : f i ⟶ f i' :=
eq_to_hom (congr_arg f h)

@[simp]
lemma congr_eq_to_hom_refl {I : Type v} {f : I → C} {i : I} :
  congr_eq_to_hom f rfl = 𝟙 (f i) :=
rfl

def congr_eq_to_iso {I : Type v} (f : I → C) {i i' : I} (h : i = i') : f i ≅ f i' :=
eq_to_iso (congr_arg f h)

@[simp]
lemma congr_eq_to_iso_refl {I : Type v} {f : I → C} {i : I} :
  congr_eq_to_iso f rfl = iso.refl (f i) :=
rfl

@[simp]
lemma congr_eq_to_iso_hom {I : Type v} {f : I → C} {i i' : I} {h : i = i'} :
  (congr_eq_to_iso f h).hom = congr_eq_to_hom f h :=
rfl

@[simp]
lemma congr_eq_to_iso_inv {I : Type v} {f : I → C} {i i' : I} {h : i = i'} :
  (congr_eq_to_iso f h).inv = congr_eq_to_hom f h.symm :=
rfl

@[simp,reassoc]
lemma limits.pi.π_congr_eq_hom {I : Type v} (f : I → C) [has_product f] {i i' : I} (h : i = i') :
  limits.pi.π f i ≫ congr_eq_to_hom f h = limits.pi.π f i' :=
by { induction h, simp, }

@[simp,reassoc]
lemma limits.sigma.congr_eq_hom_ι {I : Type v} (f : I → C) [has_coproduct f] {i i' : I} (h : i = i') :
  congr_eq_to_hom f h ≫ limits.sigma.ι f i' = limits.sigma.ι f i :=
by { induction h, simp, }

@[simp]
lemma limits.pi.π_congr_eq_hom' {I J : Type v} (f : I → C) (e : I ≃ J) [has_product (λ j, f (e.symm j))] {j j' : J} (h : e.symm j = e.symm j') :
  limits.pi.π (λ j, f (e.symm j)) j ≫ congr_eq_to_hom f h = limits.pi.π (λ j, f (e.symm j)) j' :=
by { convert limits.pi.π_congr_eq_hom (λ j, f (e.symm j)) _, simpa using h, }

@[simp]
lemma limits.sigma.congr_eq_hom_ι' {I J : Type v} (f : I → C) (e : I ≃ J) [has_coproduct (λ j, f (e.symm j))] {j j' : J} (h : e.symm j = e.symm j') :
  congr_eq_to_hom f h ≫ @limits.sigma.ι J _ _ (λ j, f (e.symm j)) _ j' = limits.sigma.ι (λ j, f (e.symm j)) j :=
by { convert limits.sigma.congr_eq_hom_ι (λ j, f (e.symm j)) _, simpa using h, }

def product_iso_of_equiv {I J : Type v} (f : I → C) (e : I ≃ J)
  [has_product f] [has_product (λ j, f (e.symm j))] :
  ∏ f ≅ ∏ (λ j, f (e.symm j)) :=
{ hom := pi.lift (λ j : J, pi.π f (e.symm j)),
  inv := pi.lift (λ i : I, pi.π (λ j, f (e.symm j)) (e i) ≫ congr_eq_to_hom f (by simp)), }

@[simp] lemma product_iso_of_equiv_hom {I J : Type v} (f : I → C) (e : I ≃ J)
  [has_product f] [has_product (λ j, f (e.symm j))] :
  (product_iso_of_equiv f e).hom = pi.lift (λ j : J, pi.π f (e.symm j)) :=
rfl

def coproduct_iso_of_equiv {I J : Type v} (f : I → C) (e : I ≃ J)
  [has_coproduct f] [has_coproduct (λ j, f (e.symm j))] :
  ∐ f ≅ ∐ (λ j, f (e.symm j)) :=
{ hom := sigma.desc (λ i : I, congr_eq_to_hom f (e.symm_apply_apply i).symm ≫ sigma.ι (λ j, f (e.symm j)) (e i)),
  inv := sigma.desc (λ j : J, sigma.ι f (e.symm j)), }

@[simp] lemma coproduct_iso_of_equiv_inv {I J : Type v} (f : I → C) (e : I ≃ J)
  [has_coproduct f] [has_coproduct (λ j, f (e.symm j))] :
  (coproduct_iso_of_equiv f e).inv = sigma.desc (λ j : J, sigma.ι f (e.symm j)) :=
rfl

section
variables [has_zero_morphisms.{v} C]

lemma product_iso_of_equiv_eq_coproduct_iso_of_equiv
  {I J : Type v} [decidable_eq I] [decidable_eq J] (f : I → C) (e : I ≃ J)
  [has_biproduct f] [has_biproduct (λ j, f (e.symm j))] :
  product_iso_of_equiv f e = coproduct_iso_of_equiv f e :=
begin
  ext1,
  apply (cancel_epi (coproduct_iso_of_equiv f e).inv).1,
  rw [(coproduct_iso_of_equiv f e).inv_hom_id],
  simp only [coproduct_iso_of_equiv_inv, product_iso_of_equiv_hom],
  ext j j',
  simp only [limits.limit.lift_π, limits.cofan.mk_π_app, limits.colimit.ι_desc_assoc,
    limits.fan.mk_π_app, category.assoc],
  erw category.id_comp,
  simp only [biproduct.ι_π],
  by_cases h : j = j'; simp [h],
end

@[simp] lemma product_iso_of_equiv_inv {I J : Type v} [decidable_eq I] [decidable_eq J] (f : I → C) (e : I ≃ J)
  [has_biproduct f] [has_biproduct (λ j, f (e.symm j))] :
  (product_iso_of_equiv f e).inv = sigma.desc (λ (j : J), @limits.sigma.ι I _ _ f _ ((e.symm) j)) :=
begin
  rw product_iso_of_equiv_eq_coproduct_iso_of_equiv,
  simp,
end

@[simp] lemma coproduct_iso_of_equiv_hom {I J : Type v} [decidable_eq I] [decidable_eq J] (f : I → C) (e : I ≃ J)
  [has_biproduct f] [has_biproduct (λ j, f (e.symm j))] :
  (coproduct_iso_of_equiv f e).hom = pi.lift (λ (j : J), @limits.pi.π I _ _ f _ ((e.symm) j)) :=
begin
  rw ←product_iso_of_equiv_eq_coproduct_iso_of_equiv,
  simp,
end

end

def product_iso_of_equiv_punit_sum {I J : Type v} (f : I → C) (e : I ≃ punit.{v+1} ⊕ J)
  [has_products.{v} C] [has_binary_products.{v} C] :
  ∏ f ≅ f (e.symm (sum.inl punit.star)) ⨯ ∏ (λ j, f (e.symm (sum.inr j))) :=
calc ∏ f ≅ ∏ (λ p, f (e.symm p))
           : product_iso_of_equiv f e -- we could use `has_limit.ext_equivalence`, but it is hard to reason about.
     ... ≅ (∏ (λ j, f (e.symm (sum.inl j)))) ⨯ (∏ (λ j, f (e.symm (sum.inr j))))
           : product_over_sum_iso _
     ... ≅ f (e.symm (sum.inl punit.star)) ⨯ ∏ (λ j, f (e.symm (sum.inr j)))
           : prod.map_iso (product_over_unique_iso (λ j, f (e.symm (sum.inl j)))) (iso.refl _)

lemma srt {I J : Type v} (f : I → C) (e : I ≃ punit.{v+1} ⊕ J)
  [has_products.{v} C] [has_binary_products.{v} C] :
(product_iso_of_equiv_punit_sum f e).hom ≫ prod.fst = pi.π f (e.symm (sum.inl punit.star)) :=
begin
  simp [product_iso_of_equiv_punit_sum], refl,
end

def product_iso_of_equiv_punit_sum' {I J : Type v} (f : I → C) (e : I ≃ punit.{v+1} ⊕ J)
  (i : I) (h : e.symm (sum.inl punit.star) = i)
  [has_products.{v} C] [has_binary_products.{v} C] :
  ∏ f ≅ f i ⨯ ∏ (λ j, f (e.symm (sum.inr j))) :=
(product_iso_of_equiv_punit_sum f e).trans
(prod.map_iso (congr_eq_to_iso f h) (iso.refl _))

-- TODO and we need to make sure `ι` plays well with this iso...
-- which may be a hassle because `has_limit.ext_of_equivalence` is so opaque

end category_theory.limits
