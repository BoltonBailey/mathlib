/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Abhimanyu Pallavi Sudhir, Jean Lo, Calle Sönne
-/
import data.complex.exponential
import analysis.complex.basic
import analysis.calculus.mean_value
import measure_theory.borel_space

/-!
# Complex and real exponential, real logarithm

## Main statements

This file establishes the basic analytical properties of the complex and real exponential functions
(continuity, differentiability, computation of the derivative).

It also contains the definition of the real logarithm function (as the inverse of the
exponential on `(0, +∞)`, extended to `ℝ` by setting `log (-x) = log x`) and its basic
properties (continuity, differentiability, formula for the derivative).

The complex logarithm is *not* defined in this file as it relies on trigonometric functions. See
instead `trigonometric.lean`.

## Tags

exp, log
-/

noncomputable theory

open finset filter metric asymptotics
open_locale classical topological_space

namespace complex

/-- The complex exponential is everywhere differentiable, with the derivative `exp x`. -/
lemma has_deriv_at_exp (x : ℂ) : has_deriv_at exp (exp x) x :=
begin
  rw has_deriv_at_iff_is_o_nhds_zero,
  have : (1 : ℕ) < 2 := by norm_num,
  refine (is_O.of_bound (∥exp x∥) _).trans_is_o (is_o_pow_id this),
  have : metric.ball (0 : ℂ) 1 ∈ nhds (0 : ℂ) := metric.ball_mem_nhds 0 zero_lt_one,
  apply filter.mem_sets_of_superset this (λz hz, _),
  simp only [metric.mem_ball, dist_zero_right] at hz,
  simp only [exp_zero, mul_one, one_mul, add_comm, normed_field.norm_pow,
             zero_add, set.mem_set_of_eq],
  calc ∥exp (x + z) - exp x - z * exp x∥
    = ∥exp x * (exp z - 1 - z)∥ : by { congr, rw [exp_add], ring }
    ... = ∥exp x∥ * ∥exp z - 1 - z∥ : normed_field.norm_mul _ _
    ... ≤ ∥exp x∥ * ∥z∥^2 :
      mul_le_mul_of_nonneg_left (abs_exp_sub_one_sub_id_le (le_of_lt hz)) (norm_nonneg _)
end

lemma differentiable_exp : differentiable ℂ exp :=
λx, (has_deriv_at_exp x).differentiable_at

lemma differentiable_at_exp {x : ℂ} : differentiable_at ℂ exp x :=
differentiable_exp x

@[simp] lemma deriv_exp : deriv exp = exp :=
funext $ λ x, (has_deriv_at_exp x).deriv

@[simp] lemma iter_deriv_exp : ∀ n : ℕ, (deriv^[n] exp) = exp
| 0 := rfl
| (n+1) := by rw [function.iterate_succ_apply, deriv_exp, iter_deriv_exp n]

lemma continuous_exp : continuous exp :=
differentiable_exp.continuous

lemma times_cont_diff_exp : ∀ {n}, times_cont_diff ℂ n exp :=
begin
  refine times_cont_diff_all_iff_nat.2 (λ n, _),
  induction n with n ihn,
  { exact times_cont_diff_zero.2 continuous_exp },
  { rw times_cont_diff_succ_iff_deriv,
    use differentiable_exp,
    rwa deriv_exp }
end

lemma measurable_exp : measurable exp := continuous_exp.measurable

end complex

section
variables {f : ℂ → ℂ} {f' x : ℂ} {s : set ℂ}

lemma has_deriv_at.cexp (hf : has_deriv_at f f' x) :
  has_deriv_at (λ x, complex.exp (f x)) (complex.exp (f x) * f') x :=
(complex.has_deriv_at_exp (f x)).comp x hf

lemma has_deriv_within_at.cexp (hf : has_deriv_within_at f f' s x) :
  has_deriv_within_at (λ x, complex.exp (f x)) (complex.exp (f x) * f') s x :=
(complex.has_deriv_at_exp (f x)).comp_has_deriv_within_at x hf

lemma deriv_within_cexp (hf : differentiable_within_at ℂ f s x)
  (hxs : unique_diff_within_at ℂ s x) :
  deriv_within (λx, complex.exp (f x)) s x = complex.exp (f x) * (deriv_within f s x) :=
hf.has_deriv_within_at.cexp.deriv_within hxs

@[simp] lemma deriv_cexp (hc : differentiable_at ℂ f x) :
  deriv (λx, complex.exp (f x)) x = complex.exp (f x) * (deriv f x) :=
hc.has_deriv_at.cexp.deriv

end

section

variables {E : Type*} [normed_group E] [normed_space ℂ E] {f : E → ℂ} {f' : E →L[ℂ] ℂ}
  {x : E} {s : set E}

lemma measurable.cexp {α : Type*} [measurable_space α] {f : α → ℂ} (hf : measurable f) :
  measurable (λ x, complex.exp (f x)) :=
complex.measurable_exp.comp hf

lemma has_fderiv_within_at.cexp (hf : has_fderiv_within_at f f' s x) :
  has_fderiv_within_at (λ x, complex.exp (f x)) (complex.exp (f x) • f') s x :=
(complex.has_deriv_at_exp (f x)).comp_has_fderiv_within_at x hf

lemma has_fderiv_at.cexp (hf : has_fderiv_at f f' x) :
  has_fderiv_at (λ x, complex.exp (f x)) (complex.exp (f x) • f') x :=
has_fderiv_within_at_univ.1 $ hf.has_fderiv_within_at.cexp

lemma differentiable_within_at.cexp (hf : differentiable_within_at ℂ f s x) :
  differentiable_within_at ℂ (λ x, complex.exp (f x)) s x :=
hf.has_fderiv_within_at.cexp.differentiable_within_at

@[simp] lemma differentiable_at.cexp (hc : differentiable_at ℂ f x) :
  differentiable_at ℂ (λx, complex.exp (f x)) x :=
hc.has_fderiv_at.cexp.differentiable_at

lemma differentiable_on.cexp (hc : differentiable_on ℂ f s) :
  differentiable_on ℂ (λx, complex.exp (f x)) s :=
λx h, (hc x h).cexp

@[simp] lemma differentiable.cexp (hc : differentiable ℂ f) :
  differentiable ℂ (λx, complex.exp (f x)) :=
λx, (hc x).cexp

lemma times_cont_diff.cexp {n} (h : times_cont_diff ℂ n f) :
  times_cont_diff ℂ n (λ x, complex.exp (f x)) :=
complex.times_cont_diff_exp.comp h

lemma times_cont_diff_at.cexp {n} (hf : times_cont_diff_at ℂ n f x) :
  times_cont_diff_at ℂ n (λ x, complex.exp (f x)) x :=
complex.times_cont_diff_exp.times_cont_diff_at.comp x hf

lemma times_cont_diff_on.cexp {n} (hf : times_cont_diff_on ℂ n f s) :
  times_cont_diff_on ℂ n (λ x, complex.exp (f x)) s :=
complex.times_cont_diff_exp.comp_times_cont_diff_on  hf

lemma times_cont_diff_within_at.cexp {n} (hf : times_cont_diff_within_at ℂ n f s x) :
  times_cont_diff_within_at ℂ n (λ x, complex.exp (f x)) s x :=
complex.times_cont_diff_exp.times_cont_diff_at.comp_times_cont_diff_within_at x hf

end

namespace real

variables {x y z : ℝ}

lemma has_deriv_at_exp (x : ℝ) : has_deriv_at exp (exp x) x :=
(complex.has_deriv_at_exp x).real_of_complex

lemma times_cont_diff_exp {n} : times_cont_diff ℝ n exp :=
complex.times_cont_diff_exp.real_of_complex

lemma differentiable_exp : differentiable ℝ exp :=
λx, (has_deriv_at_exp x).differentiable_at

lemma differentiable_at_exp : differentiable_at ℝ exp x :=
differentiable_exp x

@[simp] lemma deriv_exp : deriv exp = exp :=
funext $ λ x, (has_deriv_at_exp x).deriv

@[simp] lemma iter_deriv_exp : ∀ n : ℕ, (deriv^[n] exp) = exp
| 0 := rfl
| (n+1) := by rw [function.iterate_succ_apply, deriv_exp, iter_deriv_exp n]

lemma continuous_exp : continuous exp :=
differentiable_exp.continuous

lemma measurable_exp : measurable exp := continuous_exp.measurable

end real


section
/-! Register lemmas for the derivatives of the composition of `real.exp` with a differentiable
function, for standalone use and use with `simp`. -/

variables {f : ℝ → ℝ} {f' x : ℝ} {s : set ℝ}

lemma has_deriv_at.exp (hf : has_deriv_at f f' x) :
  has_deriv_at (λ x, real.exp (f x)) (real.exp (f x) * f') x :=
(real.has_deriv_at_exp (f x)).comp x hf

lemma has_deriv_within_at.exp (hf : has_deriv_within_at f f' s x) :
  has_deriv_within_at (λ x, real.exp (f x)) (real.exp (f x) * f') s x :=
(real.has_deriv_at_exp (f x)).comp_has_deriv_within_at x hf

lemma deriv_within_exp (hf : differentiable_within_at ℝ f s x)
  (hxs : unique_diff_within_at ℝ s x) :
  deriv_within (λx, real.exp (f x)) s x = real.exp (f x) * (deriv_within f s x) :=
hf.has_deriv_within_at.exp.deriv_within hxs

@[simp] lemma deriv_exp (hc : differentiable_at ℝ f x) :
  deriv (λx, real.exp (f x)) x = real.exp (f x) * (deriv f x) :=
hc.has_deriv_at.exp.deriv

end

section
/-! Register lemmas for the derivatives of the composition of `real.exp` with a differentiable
function, for standalone use and use with `simp`. -/

variables {E : Type*} [normed_group E] [normed_space ℝ E] {f : E → ℝ} {f' : E →L[ℝ] ℝ}
  {x : E} {s : set E}

lemma measurable.exp {α : Type*} [measurable_space α] {f : α → ℝ} (hf : measurable f) :
  measurable (λ x, real.exp (f x)) :=
real.measurable_exp.comp hf

lemma times_cont_diff.exp {n} (hf : times_cont_diff ℝ n f) :
  times_cont_diff ℝ n (λ x, real.exp (f x)) :=
real.times_cont_diff_exp.comp hf

lemma times_cont_diff_at.exp {n} (hf : times_cont_diff_at ℝ n f x) :
  times_cont_diff_at ℝ n (λ x, real.exp (f x)) x :=
real.times_cont_diff_exp.times_cont_diff_at.comp x hf

lemma times_cont_diff_on.exp {n} (hf : times_cont_diff_on ℝ n f s) :
  times_cont_diff_on ℝ n (λ x, real.exp (f x)) s :=
real.times_cont_diff_exp.comp_times_cont_diff_on  hf

lemma times_cont_diff_within_at.exp {n} (hf : times_cont_diff_within_at ℝ n f s x) :
  times_cont_diff_within_at ℝ n (λ x, real.exp (f x)) s x :=
real.times_cont_diff_exp.times_cont_diff_at.comp_times_cont_diff_within_at x hf

lemma has_fderiv_within_at.exp (hf : has_fderiv_within_at f f' s x) :
  has_fderiv_within_at (λ x, real.exp (f x)) (real.exp (f x) • f') s x :=
begin
  convert (has_deriv_at_iff_has_fderiv_at.1 $
    real.has_deriv_at_exp (f x)).comp_has_fderiv_within_at x hf,
  ext y, simp [mul_comm]
end

lemma has_fderiv_at.exp (hf : has_fderiv_at f f' x) :
  has_fderiv_at (λ x, real.exp (f x)) (real.exp (f x) • f') x :=
has_fderiv_within_at_univ.1 $ hf.has_fderiv_within_at.exp

lemma differentiable_within_at.exp (hf : differentiable_within_at ℝ f s x) :
  differentiable_within_at ℝ (λ x, real.exp (f x)) s x :=
hf.has_fderiv_within_at.exp.differentiable_within_at

@[simp] lemma differentiable_at.exp (hc : differentiable_at ℝ f x) :
  differentiable_at ℝ (λx, real.exp (f x)) x :=
hc.has_fderiv_at.exp.differentiable_at

lemma differentiable_on.exp (hc : differentiable_on ℝ f s) :
  differentiable_on ℝ (λx, real.exp (f x)) s :=
λx h, (hc x h).exp

@[simp] lemma differentiable.exp (hc : differentiable ℝ f) :
  differentiable ℝ (λx, real.exp (f x)) :=
λx, (hc x).exp

lemma fderiv_within_exp (hf : differentiable_within_at ℝ f s x)
  (hxs : unique_diff_within_at ℝ s x) :
  fderiv_within ℝ (λx, real.exp (f x)) s x = real.exp (f x) • (fderiv_within ℝ f s x) :=
hf.has_fderiv_within_at.exp.fderiv_within hxs

@[simp] lemma fderiv_exp (hc : differentiable_at ℝ f x) :
  fderiv ℝ (λx, real.exp (f x)) x = real.exp (f x) • (fderiv ℝ f x) :=
hc.has_fderiv_at.exp.fderiv

end

namespace real

variables {x y z : ℝ}

lemma exists_exp_eq_of_pos {x : ℝ} (hx : 0 < x) : ∃ y, exp y = x :=
have ∀ {z:ℝ}, 1 ≤ z → z ∈ set.range exp,
  from λ z hz, intermediate_value_univ 0 (z - 1) continuous_exp
    ⟨by simpa, by simpa using add_one_le_exp_of_nonneg (sub_nonneg.2 hz)⟩,
match le_total x 1 with
| (or.inl hx1) := let ⟨y, hy⟩ := this (one_le_inv hx hx1) in
  ⟨-y, by rw [exp_neg, hy, inv_inv']⟩
| (or.inr hx1) := this hx1
end

/-- The real logarithm function, equal to the inverse of the exponential for `x > 0`,
to `log |x|` for `x < 0`, and to `0` for `0`. We use this unconventional extension to
`(-∞, 0]` as it gives the formula `log (x * y) = log x + log y` for all nonzero `x` and `y`, and
the derivative of `log` is `1/x` away from `0`. -/
@[pp_nodot] noncomputable def log (x : ℝ) : ℝ :=
if hx : x ≠ 0 then classical.some (exists_exp_eq_of_pos (abs_pos.mpr hx)) else 0

lemma exp_log_eq_abs (hx : x ≠ 0) : exp (log x) = abs x :=
by { rw [log, dif_pos hx], exact classical.some_spec (exists_exp_eq_of_pos ((abs_pos.mpr hx))) }

lemma exp_log (hx : 0 < x) : exp (log x) = x :=
by { rw exp_log_eq_abs (ne_of_gt hx), exact abs_of_pos hx }

lemma range_exp : set.range exp = {x | 0 < x} :=
set.ext $ λ x, ⟨by { rintro ⟨x, rfl⟩, exact exp_pos x }, λ hx, ⟨log x, exp_log hx⟩⟩

lemma exp_log_of_neg (hx : x < 0) : exp (log x) = -x :=
by { rw exp_log_eq_abs (ne_of_lt hx), exact abs_of_neg hx }

@[simp] lemma log_exp (x : ℝ) : log (exp x) = x :=
exp_injective $ exp_log (exp_pos x)

lemma log_surjective : function.surjective log :=
λ x, ⟨exp x, log_exp x⟩

@[simp] lemma range_log : set.range log = set.univ :=
log_surjective.range_eq

@[simp] lemma log_zero : log 0 = 0 :=
by simp [log]

@[simp] lemma log_one : log 1 = 0 :=
exp_injective $ by rw [exp_log zero_lt_one, exp_zero]

@[simp] lemma log_abs (x : ℝ) : log (abs x) = log x :=
begin
  by_cases h : x = 0,
  { simp [h] },
  { apply exp_injective,
    rw [exp_log_eq_abs h, exp_log_eq_abs, abs_abs],
    simp [h] }
end

@[simp] lemma log_neg_eq_log (x : ℝ) : log (-x) = log x :=
by rw [← log_abs x, ← log_abs (-x), abs_neg]

lemma log_mul (hx : x ≠ 0) (hy : y ≠ 0) : log (x * y) = log x + log y :=
exp_injective $
by rw [exp_log_eq_abs (mul_ne_zero hx hy), exp_add, exp_log_eq_abs hx, exp_log_eq_abs hy, abs_mul]

@[simp] lemma log_inv (x : ℝ) : log (x⁻¹) = -log x :=
begin
  by_cases hx : x = 0, { simp [hx] },
  apply eq_neg_of_add_eq_zero,
  rw [← log_mul (inv_ne_zero hx) hx, inv_mul_cancel hx, log_one]
end

lemma log_le_log (h : 0 < x) (h₁ : 0 < y) : real.log x ≤ real.log y ↔ x ≤ y :=
⟨λ h₂, by rwa [←real.exp_le_exp, real.exp_log h, real.exp_log h₁] at h₂, λ h₂,
(real.exp_le_exp).1 $ by rwa [real.exp_log h₁, real.exp_log h]⟩

lemma log_lt_log (hx : 0 < x) : x < y → log x < log y :=
by { intro h, rwa [← exp_lt_exp, exp_log hx, exp_log (lt_trans hx h)] }

lemma log_lt_log_iff (hx : 0 < x) (hy : 0 < y) : log x < log y ↔ x < y :=
by { rw [← exp_lt_exp, exp_log hx, exp_log hy] }

lemma log_pos_iff (hx : 0 < x) : 0 < log x ↔ 1 < x :=
by { rw ← log_one, exact log_lt_log_iff (by norm_num) hx }

lemma log_pos (hx : 1 < x) : 0 < log x :=
(log_pos_iff (lt_trans zero_lt_one hx)).2 hx

lemma log_neg_iff (h : 0 < x) : log x < 0 ↔ x < 1 :=
by { rw ← log_one, exact log_lt_log_iff h (by norm_num) }

lemma log_neg (h0 : 0 < x) (h1 : x < 1) : log x < 0 := (log_neg_iff h0).2 h1

lemma log_nonneg_iff (hx : 0 < x) : 0 ≤ log x ↔ 1 ≤ x :=
by rw [← not_lt, log_neg_iff hx, not_lt]

lemma log_nonneg (hx : 1 ≤ x) : 0 ≤ log x :=
(log_nonneg_iff (zero_lt_one.trans_le hx)).2 hx

lemma log_nonpos_iff (hx : 0 < x) : log x ≤ 0 ↔ x ≤ 1 :=
by rw [← not_lt, log_pos_iff hx, not_lt]

lemma log_nonpos_iff' (hx : 0 ≤ x) : log x ≤ 0 ↔ x ≤ 1 :=
begin
  rcases hx.eq_or_lt with (rfl|hx),
  { simp [le_refl, zero_le_one] },
  exact log_nonpos_iff hx
end

lemma log_nonpos (hx : 0 ≤ x) (h'x : x ≤ 1) : log x ≤ 0 :=
(log_nonpos_iff' hx).2 h'x

section prove_log_is_continuous

lemma tendsto_log_one_zero : tendsto log (𝓝 1) (𝓝 0) :=
begin
  rw tendsto_nhds_nhds, assume ε ε0,
  let δ := min (exp ε - 1) (1 - exp (-ε)),
  have : 0 < δ,
    refine lt_min (sub_pos_of_lt (by rwa one_lt_exp_iff)) (sub_pos_of_lt _),
      by { rw exp_lt_one_iff, linarith },
  use [δ, this], assume x h,
  cases le_total 1 x with hx hx,
  { have h : x < exp ε,
      rw [dist_eq, abs_of_nonneg (sub_nonneg_of_le hx)] at h,
      linarith [(min_le_left _ _ : δ ≤ exp ε - 1)],
    calc abs (log x - 0) = abs (log x) : by simp
      ... = log x : abs_of_nonneg $ log_nonneg hx
      ... < ε : by { rwa [← exp_lt_exp, exp_log], linarith }},
  { have h : exp (-ε) < x,
      rw [dist_eq, abs_of_nonpos (sub_nonpos_of_le hx)] at h,
      linarith [(min_le_right _ _ : δ ≤ 1 - exp (-ε))],
    have : 0 < x := lt_trans (exp_pos _) h,
    calc abs (log x - 0) = abs (log x) : by simp
      ... = -log x : abs_of_nonpos $ log_nonpos (le_of_lt this) hx
      ... < ε : by { rw [neg_lt, ← exp_lt_exp, exp_log], assumption' } }
end

lemma continuous_log' : continuous (λx : {x:ℝ // 0 < x}, log x) :=
continuous_iff_continuous_at.2 $ λ x,
begin
  rw continuous_at,
  let f₁ := λ h:{h:ℝ // 0 < h}, log (x.1 * h.1),
  let f₂ := λ y:{y:ℝ // 0 < y}, subtype.mk (x.1 ⁻¹ * y.1) (mul_pos (inv_pos.2 x.2) y.2),
  have H1 : tendsto f₁ (𝓝 ⟨1, zero_lt_one⟩) (𝓝 (log (x.1*1))),
    have : f₁ = λ h:{h:ℝ // 0 < h}, log x.1 + log h.1,
      ext h, rw ← log_mul (ne_of_gt x.2) (ne_of_gt h.2),
    simp only [this, log_mul (ne_of_gt x.2) one_ne_zero, log_one],
    exact tendsto_const_nhds.add (tendsto.comp tendsto_log_one_zero continuous_at_subtype_coe),
  have H2 : tendsto f₂ (𝓝 x) (𝓝 ⟨x.1⁻¹ * x.1, mul_pos (inv_pos.2 x.2) x.2⟩),
    rw tendsto_subtype_rng, exact tendsto_const_nhds.mul continuous_at_subtype_coe,
  suffices h : tendsto (f₁ ∘ f₂) (𝓝 x) (𝓝 (log x.1)),
  begin
    convert h, ext y,
    have : x.val * (x.val⁻¹ * y.val) = y.val,
      rw [← mul_assoc, mul_inv_cancel (ne_of_gt x.2), one_mul],
    show log (y.val) = log (x.val * (x.val⁻¹ * y.val)), rw this
  end,
  exact tendsto.comp (by rwa mul_one at H1)
    (by { simp only [inv_mul_cancel (ne_of_gt x.2)] at H2, assumption })
end

lemma continuous_at_log (hx : 0 < x) : continuous_at log x :=
continuous_within_at.continuous_at (continuous_on_iff_continuous_restrict.2 continuous_log' _ hx)
  (mem_nhds_sets (is_open_lt' _) hx)

/--
Three forms of the continuity of `real.log` are provided.
For the other two forms, see `real.continuous_log'` and `real.continuous_at_log`
-/
lemma continuous_log {α : Type*} [topological_space α] {f : α → ℝ} (h : ∀a, 0 < f a)
  (hf : continuous f) : continuous (λa, log (f a)) :=
show continuous ((log ∘ @subtype.val ℝ (λr, 0 < r)) ∘ λa, ⟨f a, h a⟩),
  from continuous_log'.comp (continuous_subtype_mk _ hf)

end prove_log_is_continuous

lemma has_deriv_at_log_of_pos (hx : 0 < x) : has_deriv_at log x⁻¹ x :=
have has_deriv_at log (exp $ log x)⁻¹ x,
from (has_deriv_at_exp $ log x).of_local_left_inverse (continuous_at_log hx)
  (ne_of_gt $ exp_pos _) $ eventually.mono (mem_nhds_sets is_open_Ioi hx) @exp_log,
by rwa [exp_log hx] at this

lemma has_deriv_at_log (hx : x ≠ 0) : has_deriv_at log x⁻¹ x :=
begin
  by_cases h : 0 < x, { exact has_deriv_at_log_of_pos h },
  push_neg at h,
  convert ((has_deriv_at_log_of_pos (neg_pos.mpr (lt_of_le_of_ne h hx)))
    .comp x (has_deriv_at_id x).neg),
  { ext y, exact (log_neg_eq_log y).symm },
  { field_simp [hx] }
end

lemma measurable_log : measurable log :=
measurable_of_measurable_on_compl_singleton 0 $ continuous.measurable $
  continuous_iff_continuous_at.2 $ λ x, (real.has_deriv_at_log x.2).continuous_at.comp
    continuous_at_subtype_coe

end real

section log_differentiable
open real

variables {f : ℝ → ℝ} {x f' : ℝ} {s : set ℝ}

lemma measurable.log (hf : measurable f) : measurable (λ x, log (f x)) :=
measurable_log.comp hf

lemma has_deriv_within_at.log (hf : has_deriv_within_at f f' s x) (hx : f x ≠ 0) :
  has_deriv_within_at (λ y, log (f y)) (f' / (f x)) s x :=
begin
  convert (has_deriv_at_log hx).comp_has_deriv_within_at x hf,
  field_simp
end

lemma has_deriv_at.log (hf : has_deriv_at f f' x) (hx : f x ≠ 0) :
  has_deriv_at (λ y, log (f y)) (f' / f x) x :=
begin
  rw ← has_deriv_within_at_univ at *,
  exact hf.log hx
end

lemma differentiable_within_at.log (hf : differentiable_within_at ℝ f s x) (hx : f x ≠ 0) :
  differentiable_within_at ℝ (λx, log (f x)) s x :=
(hf.has_deriv_within_at.log hx).differentiable_within_at

@[simp] lemma differentiable_at.log (hf : differentiable_at ℝ f x) (hx : f x ≠ 0) :
  differentiable_at ℝ (λx, log (f x)) x :=
(hf.has_deriv_at.log hx).differentiable_at

lemma differentiable_on.log (hf : differentiable_on ℝ f s) (hx : ∀ x ∈ s, f x ≠ 0) :
  differentiable_on ℝ (λx, log (f x)) s :=
λx h, (hf x h).log (hx x h)

@[simp] lemma differentiable.log (hf : differentiable ℝ f) (hx : ∀ x, f x ≠ 0) :
  differentiable ℝ (λx, log (f x)) :=
λx, (hf x).log (hx x)

lemma deriv_within_log' (hf : differentiable_within_at ℝ f s x) (hx : f x ≠ 0)
  (hxs : unique_diff_within_at ℝ s x) :
  deriv_within (λx, log (f x)) s x = (deriv_within f s x) / (f x) :=
(hf.has_deriv_within_at.log hx).deriv_within hxs

@[simp] lemma deriv_log' (hf : differentiable_at ℝ f x) (hx : f x ≠ 0) :
  deriv (λx, log (f x)) x = (deriv f x) / (f x) :=
(hf.has_deriv_at.log hx).deriv

end log_differentiable

namespace real

/-- The real exponential function tends to `+∞` at `+∞`. -/
lemma tendsto_exp_at_top : tendsto exp at_top at_top :=
begin
  have A : tendsto (λx:ℝ, x + 1) at_top at_top :=
    tendsto_at_top_add_const_right at_top 1 tendsto_id,
  have B : ∀ᶠ x in at_top, x + 1 ≤ exp x :=
    eventually_at_top.2 ⟨0, λx hx, add_one_le_exp_of_nonneg hx⟩,
  exact tendsto_at_top_mono' at_top B A
end

/-- The real exponential function tends to `0` at `-∞` or, equivalently, `exp(-x)` tends to `0`
at `+∞` -/
lemma tendsto_exp_neg_at_top_nhds_0 : tendsto (λx, exp (-x)) at_top (𝓝 0) :=
(tendsto_inv_at_top_zero.comp (tendsto_exp_at_top)).congr (λx, (exp_neg x).symm)

/-- The real exponential function tends to `1` at `0`. -/
lemma tendsto_exp_nhds_0_nhds_1 : tendsto exp (𝓝 0) (𝓝 1) :=
by { convert continuous_exp.tendsto 0, simp }

/-- The function `exp(x)/x^n` tends to `+∞` at `+∞`, for any natural number `n` -/
lemma tendsto_exp_div_pow_at_top (n : ℕ) : tendsto (λx, exp x / x^n) at_top at_top :=
begin
  have n_pos : (0 : ℝ) < n + 1 := nat.cast_add_one_pos n,
  have n_ne_zero : (n : ℝ) + 1 ≠ 0 := ne_of_gt n_pos,
  have A : ∀x:ℝ, 0 < x → exp (x / (n+1)) / (n+1)^n ≤ exp x / x^n,
  { assume x hx,
    let y := x / (n+1),
    have y_pos : 0 < y := div_pos hx n_pos,
    have : exp (x / (n+1)) ≤ (n+1)^n * (exp x / x^n), from calc
      exp y = exp y * 1 : by simp
      ... ≤ exp y * (exp y / y)^n : begin
          apply mul_le_mul_of_nonneg_left (one_le_pow_of_one_le _ n) (le_of_lt (exp_pos _)),
          rw one_le_div y_pos,
          apply le_trans _ (add_one_le_exp_of_nonneg (le_of_lt y_pos)),
          exact le_add_of_le_of_nonneg (le_refl _) (zero_le_one)
        end
      ... = exp y * exp (n * y) / y^n :
        by rw [div_pow, exp_nat_mul, mul_div_assoc]
      ... = exp ((n + 1) * y) / y^n :
        by rw [← exp_add, add_mul, one_mul, add_comm]
      ... = exp x / (x / (n+1))^n :
        by { dsimp [y], rw mul_div_cancel' _ n_ne_zero }
      ... = (n+1)^n * (exp x / x^n) :
        by rw [← mul_div_assoc, div_pow, div_div_eq_mul_div, mul_comm],
    rwa div_le_iff' (pow_pos n_pos n) },
  have B : ∀ᶠ x in at_top, exp (x / (n+1)) / (n+1)^n ≤ exp x / x^n :=
    mem_at_top_sets.2 ⟨1, λx hx, A _ (lt_of_lt_of_le zero_lt_one hx)⟩,
  have C : tendsto (λx, exp (x / (n+1)) / (n+1)^n) at_top at_top :=
    tendsto_at_top_div (pow_pos n_pos n)
      (tendsto_exp_at_top.comp (tendsto_at_top_div (nat.cast_add_one_pos n) tendsto_id)),
  exact tendsto_at_top_mono' at_top B C
end

/-- The function `x^n * exp(-x)` tends to `0` at `+∞`, for any natural number `n`. -/
lemma tendsto_pow_mul_exp_neg_at_top_nhds_0 (n : ℕ) : tendsto (λx, x^n * exp (-x)) at_top (𝓝 0) :=
(tendsto_inv_at_top_zero.comp (tendsto_exp_div_pow_at_top n)).congr $ λx,
  by rw [function.comp_app, inv_eq_one_div, div_div_eq_mul_div, one_mul, div_eq_mul_inv, exp_neg]

/-- The function `(b * exp x + c) / (x ^ n)` tends to `+∞` at `+∞`, for any positive natural number
`n` and any real numbers `b` and `c` such that `b` is positive. -/
lemma tendsto_mul_exp_add_div_pow_at_top (b c : ℝ) (n : ℕ) (hb : 0 < b) (hn : 1 ≤ n) :
  tendsto (λ x, (b * (exp x) + c) / (x^n)) at_top at_top :=
begin
  refine tendsto.congr' (eventually_eq_of_mem (Ioi_mem_at_top 0) _)
    (tendsto_at_top_add_tendsto_right (tendsto_at_top_mul_left hb (tendsto_exp_div_pow_at_top n))
      ((tendsto_pow_neg_at_top hn).mul (@tendsto_const_nhds _ _ _ c _))),
  intros x hx,
  simp only [fpow_neg x n],
  ring,
end

/-- The function `(x ^ n) / (b * exp x + c)` tends to `0` at `+∞`, for any positive natural number
`n` and any real numbers `b` and `c` such that `b` is nonzero. -/
lemma tendsto_div_pow_mul_exp_add_at_top (b c : ℝ) (n : ℕ) (hb : 0 ≠ b) (hn : 1 ≤ n) :
  tendsto (λ x, x^n / (b * (exp x) + c)) at_top (𝓝 0) :=
begin
  have H : ∀ d e, 0 < d → tendsto (λ (x:ℝ), x^n / (d * (exp x) + e)) at_top (𝓝 0),
  { intros b' c' h,
    convert tendsto.inv_tendsto_at_top (tendsto_mul_exp_add_div_pow_at_top b' c' n h hn),
    ext x,
    simpa only [pi.inv_apply] using inv_div.symm },
  cases lt_or_gt_of_ne hb,
  { exact H b c h },
  { convert (H (-b) (-c) (neg_pos.mpr h)).neg,
    { ext x,
      field_simp,
      rw [← neg_add (b * exp x) c, neg_div_neg_eq] },
    { exact neg_zero.symm } },
end

/-- The real logarithm function tends to `+∞` at `+∞`. -/
lemma tendsto_log_at_top : tendsto log at_top at_top :=
begin
  rw tendsto_at_top_at_top,
  intro b,
  use exp b,
  intros a hab,
  rw [← exp_le_exp, exp_log_eq_abs (ne_of_gt $ lt_of_lt_of_le (exp_pos b) hab)],
  exact le_trans hab (le_abs_self a)
end

open_locale big_operators

/-- A crude lemma estimating the difference between `log (1-x)` and its Taylor series at `0`,
where the main point of the bound is that it tends to `0`. The goal is to deduce the series
expansion of the logarithm, in `has_sum_pow_div_log_of_abs_lt_1`.
-/
lemma abs_log_sub_add_sum_range_le {x : ℝ} (h : abs x < 1) (n : ℕ) :
  abs ((∑ i in range n, x^(i+1)/(i+1)) + log (1-x)) ≤ (abs x)^(n+1) / (1 - abs x) :=
begin
  /- For the proof, we show that the derivative of the function to be estimated is small,
  and then apply the mean value inequality. -/
  let F : ℝ → ℝ := λ x, ∑ i in range n, x^(i+1)/(i+1) + log (1-x),
  -- First step: compute the derivative of `F`
  have A : ∀ y ∈ set.Ioo (-1 : ℝ) 1, deriv F y = - (y^n) / (1 - y),
  { assume y hy,
    have : (∑ i in range n, (↑i + 1) * y ^ i / (↑i + 1)) = (∑ i in range n, y ^ i),
    { congr' with i,
      have : (i : ℝ) + 1 ≠ 0 := ne_of_gt (nat.cast_add_one_pos i),
      field_simp [this, mul_comm] },
    field_simp [F, this, ← geom_series_def, geom_sum (ne_of_lt hy.2),
                sub_ne_zero_of_ne (ne_of_gt hy.2), sub_ne_zero_of_ne (ne_of_lt hy.2)],
    ring },
  -- second step: show that the derivative of `F` is small
  have B : ∀ y ∈ set.Icc (-abs x) (abs x), abs (deriv F y) ≤ (abs x)^n / (1 - abs x),
  { assume y hy,
    have : y ∈ set.Ioo (-(1 : ℝ)) 1 := ⟨lt_of_lt_of_le (neg_lt_neg h) hy.1, lt_of_le_of_lt hy.2 h⟩,
    calc abs (deriv F y) = abs (-(y^n) / (1 - y)) : by rw [A y this]
    ... ≤ (abs x)^n / (1 - abs x) :
      begin
        have : abs y ≤ abs x := abs_le.2 hy,
        have : 0 < 1 - abs x, by linarith,
        have : 1 - abs x ≤ abs (1 - y) := le_trans (by linarith [hy.2]) (le_abs_self _),
        simp only [← pow_abs, abs_div, abs_neg],
        apply_rules [div_le_div, pow_nonneg, abs_nonneg, pow_le_pow_of_le_left]
      end },
  -- third step: apply the mean value inequality
  have C : ∥F x - F 0∥ ≤ ((abs x)^n / (1 - abs x)) * ∥x - 0∥,
  { have : ∀ y ∈ set.Icc (- abs x) (abs x), differentiable_at ℝ F y,
    { assume y hy,
      have : 1 - y ≠ 0 := sub_ne_zero_of_ne (ne_of_gt (lt_of_le_of_lt hy.2 h)),
      simp [F, this] },
    apply convex.norm_image_sub_le_of_norm_deriv_le this B (convex_Icc _ _) _ _,
    { simpa using abs_nonneg x },
    { simp [le_abs_self x, neg_le.mp (neg_le_abs_self x)] } },
  -- fourth step: conclude by massaging the inequality of the third step
  simpa [F, norm_eq_abs, div_mul_eq_mul_div, pow_succ'] using C
end

/-- Power series expansion of the logarithm around `1`. -/
theorem has_sum_pow_div_log_of_abs_lt_1 {x : ℝ} (h : abs x < 1) :
  has_sum (λ (n : ℕ), x ^ (n + 1) / (n + 1)) (-log (1 - x)) :=
begin
  rw summable.has_sum_iff_tendsto_nat,
  show tendsto (λ (n : ℕ), ∑ (i : ℕ) in range n, x ^ (i + 1) / (i + 1)) at_top (𝓝 (-log (1 - x))),
  { rw [tendsto_iff_norm_tendsto_zero],
    simp only [norm_eq_abs, sub_neg_eq_add],
    refine squeeze_zero (λ n, abs_nonneg _) (abs_log_sub_add_sum_range_le h) _,
    suffices : tendsto (λ (t : ℕ), abs x ^ (t + 1) / (1 - abs x)) at_top
      (𝓝 (abs x * 0 / (1 - abs x))), by simpa,
    simp only [pow_succ],
    refine (tendsto_const_nhds.mul _).div_const,
    exact tendsto_pow_at_top_nhds_0_of_lt_1 (abs_nonneg _) h },
  show summable (λ (n : ℕ), x ^ (n + 1) / (n + 1)),
  { refine summable_of_norm_bounded _ (summable_geometric_of_lt_1 (abs_nonneg _) h) (λ i, _),
    calc ∥x ^ (i + 1) / (i + 1)∥
    = abs x ^ (i+1) / (i+1) :
      begin
        have : (0 : ℝ) ≤ i + 1 := le_of_lt (nat.cast_add_one_pos i),
        rw [norm_eq_abs, abs_div, ← pow_abs, abs_of_nonneg this],
      end
    ... ≤ abs x ^ (i+1) / (0 + 1) :
      begin
        apply_rules [div_le_div_of_le_left, pow_nonneg, abs_nonneg, add_le_add_right,
          i.cast_nonneg],
        norm_num,
      end
    ... ≤ abs x ^ i :
      by simpa [pow_succ'] using mul_le_of_le_one_right (pow_nonneg (abs_nonneg x) i) (le_of_lt h) }
end

end real
