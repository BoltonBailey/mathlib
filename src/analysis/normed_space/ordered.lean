import analysis.normed_space.basic
import algebra.ring.basic

open filter
open_locale topological_space

class normed_linear_ordered_group (α : Type*)
extends linear_ordered_add_comm_group α, has_norm α, metric_space α :=
(dist_eq : ∀ x y, dist x y = norm (x - y))

instance normed_linear_ordered_group.to_normed_group (α : Type*)
  [normed_linear_ordered_group α] : normed_group α :=
⟨normed_linear_ordered_group.dist_eq⟩

class normed_linear_ordered_field (α : Type*)
extends linear_ordered_field α, has_norm α, metric_space α :=
(dist_eq : ∀ x y, dist x y = norm (x - y))
(norm_mul' : ∀ a b, norm (a * b) = norm a * norm b)

instance normed_linear_ordered_field.to_normed_field (α : Type*)
  [normed_linear_ordered_field α] : normed_field α :=
{ dist_eq := normed_linear_ordered_field.dist_eq,
  norm_mul' := normed_linear_ordered_field.norm_mul' }

instance normed_linear_ordered_field.to_normed_linear_ordered_group (α : Type*)
[normed_linear_ordered_field α] : normed_linear_ordered_group α :=
⟨normed_linear_ordered_field.dist_eq⟩

lemma tendsto_pow_div_pow_at_top_of_lt {α : Type*} [normed_linear_ordered_field α] [order_topology α]
  {p q : ℕ} (hpq : p < q) : tendsto (λ (x : α), x^p / x^q) at_top (𝓝 0) :=
begin
  suffices h : tendsto (λ (x : α), x ^ ((p : ℤ) - q)) at_top (𝓝 0),
  { refine (tendsto_congr' ((eventually_gt_at_top (0 : α)).mono (λ x hx, _))).mp h,
    simp [fpow_sub hx.ne.symm] },
  rw ← neg_sub,
  rw ← int.coe_nat_sub hpq.le,
  have : 1 ≤ q - p := nat.sub_pos_of_lt hpq,
  exact @tendsto_pow_neg_at_top α _ _ (by apply_instance) _ this,
end
