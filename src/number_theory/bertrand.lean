import data.nat.prime
import data.nat.choose
import data.nat.multiplicity
import ring_theory.multiplicity
import tactic

open_locale big_operators

def α (n : nat) (pos : 0 < n) (p : nat) (is_prime : nat.prime p) : nat :=
  (multiplicity p (nat.choose (2 * n) n)).get $
  begin
    have not_one : p ≠ 1 := nat.prime.ne_one is_prime,
    have pos : 0 < nat.choose (2 * n) n := nat.choose_pos (by linarith),
    have fin : multiplicity.finite p (nat.choose (2 * n) n) :=
      (@multiplicity.finite_nat_iff p (nat.choose (2 * n) n)).2 ⟨not_one, pos⟩,
    exact (multiplicity.finite_iff_dom.1 fin),
  end

lemma claim_1
  (p : nat)
  (is_prime : nat.prime p)
  (n : nat)
  (n_big : 3 < n)
  : pow p (α n (by linarith) p is_prime) ≤ 2 * n
  :=
begin
unfold α,
simp only [@nat.prime.multiplicity_choose p (2 * n) n _ is_prime (by linarith) (le_refl (2 * n))],
have r : 2 * n - n = n, by
  calc 2 * n - n = n + n - n: by rw two_mul n
  ... = n: nat.add_sub_cancel n n,
simp [r],

end

lemma add_two_not_le_one (x : nat) (pr : x.succ.succ ≤ 1) : false :=
  nat.not_succ_le_zero x (nat.lt_succ_iff.mp pr)

lemma filter_Ico_bot (m n : nat) (size : m < n) : finset.filter (λ x, x ≤ m) (finset.Ico m n) = {m} :=
begin
  ext,
  split,
  { intros hyp,
    simp only [finset.Ico.mem, finset.mem_filter] at hyp,
    simp only [finset.mem_singleton],
    linarith, },
  { intros singleton,
    rw finset.mem_singleton at singleton,
    subst singleton,
    simp,
    exact ⟨ ⟨ le_refl a, size ⟩, le_refl a ⟩ }
end

lemma card_singleton_inter {A : Type*} [d : decidable_eq A] {x : A} {s : finset A} : finset.card ({x} ∩ s) ≤ 1 :=
begin
  cases (finset.decidable_mem x s),
  { rw finset.singleton_inter_of_not_mem h,
    simp, },
  { rw finset.singleton_inter_of_mem h,
    simp, }
end

lemma claim_2
  (p : nat)
  (is_prime : nat.prime p)
  (n : nat)
  (n_big : 3 < n)
  (smallish : (2 * n) < p ^ 2)
  : (α n (by linarith) p is_prime) ≤ 1
  :=
begin
  unfold α,
  simp only [@nat.prime.multiplicity_choose p (2 * n) n _ is_prime (by linarith) (le_refl (2 * n))],
  have r : 2 * n - n = n, by
    calc 2 * n - n = n + n - n: by rw two_mul n
    ... = n: nat.add_sub_cancel n n,
  simp only [r, finset.filter_congr_decidable],
  have s : ∀ i, p ^ i ≤ n % p ^ i + n % p ^ i → i ≤ 1, by
    { intros i pr,
      cases le_or_lt i 1, {exact h,},
      { exfalso,
        have u : 2 * n < 2 * (n % p ^ i), by
          calc 2 * n < p ^ 2 : smallish
          ... ≤ p ^ i : nat.pow_le_pow_of_le_right (nat.prime.pos is_prime) h
          ... ≤ n % p ^ i + n % p ^ i : pr
          ... = 2 * (n % p ^ i) : (two_mul _).symm,
        have v : n < n % p ^ i, by linarith,
        have w : n % p ^ i ≤ n, exact (nat.mod_le _ _),
        linarith, }, },
  have t : ∀ x ∈ finset.Ico 1 (2 * n), p ^ x ≤ n % p ^ x + n % p ^ x ↔ (x ≤ 1 ∧ p ^ x ≤ n % p ^ x + n % p ^ x), by
    {
      intros x size,
      split,
      { intros bound, split, exact s x bound, exact bound, },
      { intros size2,
        cases x,
        { simp at size, trivial, },
        { cases x,
          { exact size2.right, },
          { exfalso, exact add_two_not_le_one _ (size2.left), }, }, },
    },
  simp only [finset.filter_congr t],
  simp only [finset.filter_and],
  simp only [filter_Ico_bot 1 (2 * n) (by linarith)],
  exact card_singleton_inter,
end

lemma prime_pow_bound : ∀ (a : nat) (p : nat) (pr : nat.prime p) (hyp : p ^ a < 3), (a = 0) ∨ (p = 2 ∧ a = 1)
| 0 := λ _ _ _, or.inl rfl
| 1 := λ p pr hyp, or.inr ⟨begin simp at hyp, interval_cases p, norm_num at pr, norm_num at pr, end, rfl⟩
| (a + 2) := begin
intros p prime hyp,
exfalso,
have s : 1 < p, by exact nat.prime.one_lt prime,
sorry,
end

lemma mod_nonzero : ∀ (n m : nat) (r : 0 < n % m), 0 < n
| 0 := λ m pr, by { simp only [nat.zero_mod] at pr, linarith }
| (n + 1) := λ _ _, nat.succ_pos n

lemma decr : ∀ n, 0 < n → ∃ m, m + 1 = n
| 0 := λ bad, by linarith
| (n + 1) := λ _, ⟨n, by simp⟩

lemma foo (n p : nat) (big : 2 * n ≤ 3 * p) : 3 * (n % p) < n :=
begin
  have r : n % p + p * (n / p) = n, by exact nat.mod_add_div n p,
  have s : 3 * (n % p) + (3 * p) * (n / p) = 3 * n, by
    calc 3 * (n % p) + (3 * p) * (n / p) = 3 * (n % p) + 3 * (p * (n / p)) : by rw ←mul_assoc 3 p (n / p)
    ... = 3 * (n % p + (p * (n / p))) : by ring
    ... = 3 * n : by rw r,

  have tt : (2 * n) * (n / p) ≤ (3 * p) * (n / p), by exact nat.mul_le_mul_right (n / p) big,
  have t : 3 * (n % p) + (2 * n) * (n / p) < 3 * n,
end

lemma claim_3
  (p : nat)
  (is_prime : nat.prime p)
  (n : nat)
  (n_big : 3 < n)
  (small : p ≤ n)
  (big : 2 * n < 3 * p)
  : α n (by linarith) p is_prime = 0
  :=
begin
  unfold α,
  simp only [@nat.prime.multiplicity_choose p (2 * n) n _ is_prime (by linarith) (le_refl (2 * n))],
  have r : 2 * n - n = n, by
    calc 2 * n - n = n + n - n: by rw two_mul n
    ... = n: nat.add_sub_cancel n n,
  simp only [r, finset.filter_congr_decidable],
  have s : finset.filter (λ i, p ^ i ≤ n % p ^ i + n % p ^ i) (finset.Ico 1 (2 * n)) = ∅,
    { ext,
      split,
      { intros a_mem,
        exfalso,
        simp only [finset.Ico.mem, finset.mem_filter] at a_mem,
        rcases a_mem with ⟨ ⟨ a_geq_1 , a_le_twon ⟩ , sized ⟩,
        have t : p ^ a < 3 * p, by
          calc p ^ a ≤ n % p ^ a + n % p ^ a : sized
            ... = 2 * (n % p ^ a) : (two_mul _).symm
            ... ≤ 2 * n : by { have w : n % p ^ a ≤ n, exact (nat.mod_le _ _), linarith, }
            ... < 3 * p : big,
        cases a,
        { linarith, },
        {
          have r : p ^ a.succ = p ^ a * p, by refl,
          rw r at t,
          have bad : p ^ a < 3, by simpa [nat.prime.pos is_prime] using t,
          rcases prime_pow_bound a p is_prime bad with a_zero,
          { subst a_zero, tidy, },
          { cases h, subst h_left, linarith, }
        }
      },
      { intros bad, simp at bad, trivial, },
    },
  simp [s],
-- Have p appearing twice in the factorisation of (2n)!
-- but only once in n!
-- and hence no times in 2n!/n!n!
end

lemma bertrand_eventually (n : nat) (n_big : 750 ≤ n) : ∃ p, nat.prime p ∧ n < p ∧ p ≤ 2 * n :=
begin
sorry
end

theorem bertrand (n : nat) (n_pos : 0 < n) : ∃ p, nat.prime p ∧ n < p ∧ p ≤ 2 * n :=
begin
cases le_or_lt 750 n,
{exact bertrand_eventually n h},
cases le_or_lt 376 n,
{ use 751, norm_num, split, linarith, linarith, },
clear h,
cases le_or_lt 274 n,
{ use 547, norm_num, split, linarith, linarith, },
clear h_1,
cases le_or_lt 139 n,
{ use 277, norm_num, split, linarith, linarith, },
clear h,
cases le_or_lt 70 n,
{ use 139, norm_num, split, linarith, linarith, },
clear h_1,
cases le_or_lt 37 n,
{ use 73, norm_num, split, linarith, linarith, },
clear h,
cases le_or_lt 19 n,
{ use 37, norm_num, split, linarith, linarith, },
clear h_1,
cases le_or_lt 11 n,
{ use 19, norm_num, split, linarith, linarith, },
clear h,
cases le_or_lt 6 n,
{ use 11, norm_num, split, linarith, linarith, },
clear h_1,
cases le_or_lt 4 n,
{ use 7, norm_num, split, linarith, linarith, },
clear h,
interval_cases n,
{ use 2, norm_num },
{ use 3, norm_num },
{ use 5, norm_num },
end


-/
