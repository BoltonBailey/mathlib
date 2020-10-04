/-
Copyright (c) 2020 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa
-/

import data.polynomial.degree.basic
import data.polynomial.degree.to_basic
import data.polynomial.degree.erase_leading
import data.polynomial.degree.to_trailing_degree
import data.polynomial.degree.trailing_degree

open polynomial finsupp finset

namespace polynomial

variables {R : Type*} [semiring R] {f : polynomial R}

open erase_leading

namespace rev
/-- rev_at is a function of two natural variables (N,i).  If i ≤ N, then rev_at N i returns N-i, otherwise it returns N.  Essentially, this function is only used for i ≤ N. -/
def rev_at (N : ℕ) : ℕ → ℕ := λ i : ℕ , ite (i ≤ N) (N-i) i

@[simp] lemma rev_at_invol {N n : ℕ} : rev_at N (rev_at N n) = n :=
begin
  unfold rev_at,
  split_ifs,
    { exact nat.sub_sub_self h, },
    { exfalso,
      apply h_1,
      exact nat.sub_le N n, },
    { refl, },
end

@[simp] lemma rev_at_small {N n : ℕ} (H : n ≤ N) : rev_at N n = N-n :=
begin
  unfold rev_at,
  split_ifs,
  refl,
end

/-- mon is the property of being monotone non-increasing. -/
def mon {α β : Type*} [linear_order α] [linear_order β] (f : α → β) := ∀ ⦃x y : α⦄, x ≤ y → f y ≤ f x

lemma min_max_mon {α β : Type*} [decidable_linear_order α] [decidable_linear_order β]
  {s : finset α} (hs : s.nonempty) {f : α → β} (mf : mon f) :
  max' (image f s) (hs.image f) = f (min' s hs) :=
begin
  apply le_antisymm,
    { refine (image f s).max'_le (nonempty.image hs f) (f (min' s hs)) _,
      intros x hx,
      rw mem_image at hx,
      rcases hx with ⟨ b , bs , rfl⟩,
      apply mf,
      apply min'_le,
      assumption, },
    { apply le_max',
      refine mem_image_of_mem f _,
      exact min'_mem s hs, },
end

/-- monotone_rev_at N _ coincides with rev_at N _ in the range [0,..,N].  I use monotone_rev_at just to show that rev_at exchanges mins and maxs.  If you can find an alternative proof that does not use this definition, then it can be removed! -/
def monotone_rev_at (N : ℕ) : ℕ → ℕ := λ i : ℕ , (N-i)

lemma min_max {s : finset ℕ} {hs : s.nonempty} : max' (image (monotone_rev_at (max' s hs)) s) (by exact nonempty.image hs (monotone_rev_at (max' s hs))) = monotone_rev_at (max' s hs) (min' s hs) :=
begin
  refine min_max_mon hs _,
  intros x y hxy,
  unfold monotone_rev_at,
  rw nat.sub_le_iff,
  by_cases xle : x ≤ (s.max' hs),
    { rwa nat.sub_sub_self xle, },
    { rw not_le at xle,
      apply le_of_lt,
      convert gt_of_ge_of_gt hxy xle,
      convert nat.sub_zero (s.max' hs),
      rw nat.sub_eq_zero_iff_le,
      exact le_of_lt xle, },
end

lemma monotone_rev_at_eq_rev_at_small {N n : ℕ} (n ≤ N) : monotone_rev_at N n = rev_at N n :=
begin
  unfold monotone_rev_at,
  rw rev_at_small H,
end

/-- reflect of a natural number N and a polynomial f, applies the function rev_at to the exponents of the terms appearing in the expansion of f.  In practice, reflect is only used when N is at least as large as the degree of f.  Eventually, it will be used with N exactly equal to the degree of f.  -/
def reflect : ℕ → polynomial R → polynomial R := λ N : ℕ , λ f : polynomial R , ⟨ (rev_at N '' ↑(f.support)).to_finset , λ i : ℕ , f.coeff (rev_at N i) , begin
  simp_rw [set.mem_to_finset, set.mem_image, mem_coe, mem_support_iff],
  intro,
  split,
    { intro a_1,
      rcases a_1 with ⟨ a , ha , rfl⟩,
      rwa rev_at_invol, },
    { intro,
      use (rev_at N a),
      rwa [rev_at_invol, eq_self_iff_true, and_true], },
end ⟩

@[simp] lemma reflect_zero {n : ℕ} : reflect n (0 : polynomial R) = 0 :=
begin
  refl,
end

@[simp] lemma reflect_add {f g : polynomial R} {n : ℕ} : reflect n (f+g) = reflect n f + reflect n g :=
begin
  ext1,
  unfold reflect,
  simp only [coeff_mk, coeff_add],
end

@[simp] lemma reflect_smul (N : ℕ) {r : R} : reflect N (C r * f) = C r * (reflect N f) :=
begin
  ext1,
  unfold reflect,
  simp only [coeff_mk, coeff_C_mul],
end

@[simp] lemma reflect_C_mul_X_pow (N n : ℕ) {c : R} : reflect N (C c * X ^ n) = C c * X ^ (rev_at N n) :=
begin
  ext1,
  unfold reflect,
  rw coeff_mk,
  by_cases h : rev_at N n = n_1,
    { rw [h, coeff_C_mul, coeff_C_mul, coeff_X_pow_self, ← h, rev_at_invol, coeff_X_pow_self], },
    { rw not_mem_support_iff_coeff_zero.mp,
        { symmetry,
          apply not_mem_support_iff_coeff_zero.mp,
          intro,
          apply h,
          exact (mem_support_C_mul_X_pow a).symm, },
        { intro,
          apply h,
          rw ← @rev_at_invol N n_1,
          apply congr_arg _,
          exact (mem_support_C_mul_X_pow a).symm, }, },
end

@[simp] lemma reflect_monomial (N n : ℕ) : reflect N ((X : polynomial R) ^ n) = X ^ (rev_at N n) :=
begin
  rw [← one_mul (X^n), ← one_mul (X^(rev_at N n)), ← C_1, reflect_C_mul_X_pow],
end

/-- The reverse of a polynomial f is the polynomial obtained by "reading f backwards".  Even though this is not the actual definition, reverse f = f (1/X) * X ^ f.nat_degree. -/
def reverse : polynomial R → polynomial R := λ f , reflect f.nat_degree f

lemma nat_degree_add_of_mul_leading_coeff_nonzero (f g: polynomial R) (fg: f.leading_coeff * g.leading_coeff ≠ 0) :
 (f * g).nat_degree = f.nat_degree + g.nat_degree :=
begin
--  apply coeff_mul_degree_add_degree f g,
  apply le_antisymm,
    { exact nat_degree_mul_le, },
    { apply le_nat_degree_of_mem_supp,
      rw mem_support_iff_coeff_ne_zero,
      convert fg,
      exact coeff_mul_degree_add_degree f g, },
end

lemma pol_ind_Rhom_prod_on_card (cf cg : ℕ) {rp : ℕ → polynomial R → polynomial R}
 (rp_add  : ∀ f g : polynomial R , ∀ F : ℕ ,
  rp F (f+g) = rp F f + rp F g)
 (rp_smul : ∀ f : polynomial R , ∀ r : R , ∀ F : ℕ ,
  rp F ((C r)*f) = C r * rp F f)
 (rp_mon : ∀ n N : ℕ , n ≤ N →
  rp N (X^n) = X^(N-n)) :
 ∀ N O : ℕ , ∀ f g : polynomial R ,
 f.support.card ≤ cf.succ → g.support.card ≤ cg.succ → f.nat_degree ≤ N → g.nat_degree ≤ O →
 (rp (N + O) (f*g)) = (rp N f) * (rp O g) :=
begin
  have rp_zero : ∀ T : ℕ , rp T (0 : polynomial R) = 0,
    intro,
    rw [← zero_mul (1 : polynomial R), ← C_0, rp_smul (1 : polynomial R) 0 T, C_0, zero_mul, zero_mul],
  induction cf with cf hcf,
  --first induction: base case
    { induction cg with cg hcg,
    -- second induction: base case
      { intros N O f g Cf Cg Nf Og,
        rw [C_mul_X_pow_of_card_support_le_one Cf, C_mul_X_pow_of_card_support_le_one Cg],
        rw [mul_assoc, X_pow_mul, mul_assoc, ← pow_add X],
        repeat {rw rp_smul},
        rw [rp_mon _ _ Nf, rp_mon _ _ Og, rp_mon],
          { rw [mul_assoc, X_pow_mul, mul_assoc, ← pow_add X],
            congr,
            rcases (nat.le.dest Og) with ⟨ G , rfl ⟩ ,
            rcases (nat.le.dest Nf) with ⟨ F , rfl ⟩ ,
            repeat {rw nat.add_sub_cancel_left},
            rw [add_comm _ F, add_comm G F, add_assoc, nat.add_sub_assoc], --
            rw [← add_assoc, add_comm f.nat_degree _, add_comm (_+f.nat_degree) G, nat.add_sub_cancel],
            rw add_comm,
            exact add_le_add_left Og f.nat_degree, },
          { rw add_comm N O,
            exact add_le_add Og Nf, }, },
    -- second induction: induction step
      { intros N O f g Cf Cg Nf Og,
        by_cases g0 : g = 0,
          { rw [g0, mul_zero, rp_zero, rp_zero, mul_zero], },
          { rw [sum_leading_C_mul_X_pow g, mul_add, rp_add, rp_add, mul_add],
            rw hcg N O f _ Cf _ Nf (le_trans nat_degree_le Og),
            rw hcg N O f _ Cf (le_add_left card_support_C_mul_X_pow_le_one) Nf _,
              { exact (le_trans (nat_degree_C_mul_X_pow_le g.leading_coeff g.nat_degree) Og), },
              { rw ← nat.lt_succ_iff,
                exact gt_of_ge_of_gt Cg (support_card_lt g0), }, }, }, },
  --first induction: induction step
    { intros N O f g Cf Cg Nf Og,
      by_cases f0 : f=0,
        { rw [f0, zero_mul, rp_zero, rp_zero, zero_mul], },
        { rw [sum_leading_C_mul_X_pow f, add_mul, rp_add, rp_add, add_mul],
          rw hcf N O _ g _ Cg (le_trans nat_degree_le Nf) Og,
          rw hcf N O _ g (le_add_left card_support_C_mul_X_pow_le_one) Cg _ Og,
            { exact (le_trans (nat_degree_C_mul_X_pow_le f.leading_coeff f.nat_degree) Nf), },
            { rw ← nat.lt_succ_iff,
              exact gt_of_ge_of_gt Cf (support_card_lt f0), }, }, },
end

lemma pol_ind_Rhom_prod {rp : ℕ → polynomial R → polynomial R}
 (rp_add  : ∀ f g : polynomial R , ∀ F : ℕ ,
  rp F (f+g) = rp F f + rp F g)
 (rp_smul : ∀ f : polynomial R , ∀ r : R , ∀ F : ℕ ,
  rp F ((C r)*f) = C r * rp F f)
 (rp_mon : ∀ n N : ℕ , n ≤ N →
  rp N (X^n) = X^(N-n)) :
 ∀ N O : ℕ , ∀ f g : polynomial R ,
 f.nat_degree ≤ N → g.nat_degree ≤ O →
 (rp (N + O) (f*g)) = (rp N f) * (rp O g) :=
begin
  intros N O f g,
  apply pol_ind_Rhom_prod_on_card f.support.card g.support.card rp_add rp_smul rp_mon,
    { exact (f.support).card.le_succ, },
    { exact (g.support).card.le_succ, },
end

@[simp] theorem reflect_mul {f g : polynomial R} {F G : ℕ} (Ff : f.nat_degree ≤ F) (Gg : g.nat_degree ≤ G) :
 reflect (F+G) (f*g) = reflect F f * reflect G g :=
begin
  apply pol_ind_Rhom_prod,
    { apply reflect_add, },
    { intros f r F,
      rw reflect_smul, },
    { intros n N Nn,
      rw [reflect_monomial, rev_at_small Nn], },
    repeat { assumption },
end

theorem reverse_mul (f g : polynomial R) {fg : f.leading_coeff*g.leading_coeff ≠ 0} :
 reverse (f*g) = reverse f * reverse g :=
begin
  unfold reverse,
  convert reflect_mul (le_refl _) (le_refl _),
    exact nat_degree_add_of_mul_leading_coeff_nonzero f g fg,
end

lemma leading_eq_trailing : leading_coeff (reverse f) = trailing_coeff f :=
begin
  by_cases f0 : f=0,
  unfold reverse,
    { rw [f0, reflect_zero, leading_coeff, trailing_coeff, coeff_zero, coeff_zero], },
  have : (reverse f).leading_coeff = (reverse f).coeff (reverse f).nat_degree, by congr,
  rw this,
  have : f.trailing_coeff = f.coeff f.nat_trailing_degree, by congr,
  rw this,
  rw nat_degree_eq_support_min'_trailing f0,
  rw nat_degree_eq_support_max' _,
  unfold reverse,
  unfold reflect,
  simp_rw monotone_rev_at_eq_rev_at_small,
  apply min_max monotone_rev_at,
  unfold rev_at,
--  tidy,

  sorry,
end

end rev
end polynomial
