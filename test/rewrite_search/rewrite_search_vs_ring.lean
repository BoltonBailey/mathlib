import tactic.ring
import tactic.rewrite_search

open tactic.rewrite_search.strategy
open tactic.rewrite_search.metric
open tactic.rewrite_search.tracer

namespace tactic.rewrite_search.vs_ring

attribute [search] add_comm add_assoc
attribute [search] mul_comm mul_assoc mul_one
attribute [search] left_distrib right_distrib
-- attribute [search] pow_two add_sub_cancel sub_add_cancel mul_sub add_sub
constants a b c d e : ℚ

lemma test2  : (a + b)*(a - b) = a^2 - b^2 :=
begin
  rw [right_distrib, mul_sub, mul_sub, pow_two, pow_two, add_sub, mul_comm b a, sub_add_cancel],
end
-- by rewrite_search {explain := tt, trace_summary := tt, metric := edit_distance}

lemma test3 : (a * (b + c)) * d = a * (b * d) + a * (c * d) :=
by rewrite_search {explain := tt, trace_summary := tt, metric := edit_distance}

lemma test4_ring : (a * (b + c + 1)) * d = a * (b * d) + a * (1 * d) + a * (c * d) :=
by ring

lemma test4 : (a * (b + c + 1)) * d = a * (b * d) + a * (1 * d) + a * (c * d) :=
by rewrite_search {explain := tt, trace_summary := tt, metric := edit_distance {refresh_freq := 3} weight.cm, strategy := pexplore, max_iterations := 100}

lemma test5_ring : (a * (b + c + 1) / e) * d = a * (b / e * d) + a * (1 / e * d) + a * (c / e * d) :=
by ring

-- lemma test5 : (a * (b + c + 1) / e) * d = a * (b / e * d) + a * (1 / e * d) + a * (c / e * d) :=
-- by rewrite_search {explain := tt, trace_summary := tt, no visualiser}

-- lemma test5_2 : (a * (b + c + 1) / e) * d = a * (b / e * d) + a * (1 / e * d) + a * (c / e * d) :=
-- by rewrite_search [add_comm, add_assoc, mul_one, mul_assoc, /-mul_comm,-/ left_distrib, right_distrib] {explain := tt, trace_summary := tt, no visualiser, metric.edit_distance {refresh_freq := 10} cm, strategy.pexplore {pop_size := 5}, max_iterations := 500}

-- lemma test5_bfs : (a * (b + c + 1) / e) * d = a * (b / e * d) + a * (1 / e * d) + a * (c / e * d) :=
-- by rewrite_search [add_comm, add_assoc, mul_one, mul_assoc, /-mul_comm,-/ left_distrib, right_distrib] {explain := tt, trace_summary := tt, no visualiser, metric.edit_distance {refresh_freq := 3} svm, strategy := bfs, max_iterations := 2000}

end tactic.rewrite_search.vs_ring
