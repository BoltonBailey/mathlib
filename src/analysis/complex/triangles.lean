import analysis.complex.basic
import data.zmod.basic
import measure_theory.interval_integral

noncomputable theory

open_locale classical
open_locale nnreal
open_locale big_operators
open_locale topological_space
open set function finset
open complex

/-- A triangle is a function from `ℤ/3ℤ` to `ℂ` (this definition allows for the description of
adjacent vertices as `i` and `i + 1`, cyclically). -/
def triangle := zmod 3 → ℂ

/-- Given a function `f : ℂ → ℂ`, the contour integral of `f` along the segment from `a` to `b` is
defined to be the (real) integral from `0` to `1` of the function
`λ t, f ((1 - t) * a + t * b) * (b - a)`. -/
def contour_integral_segment (f : ℂ → ℂ) (a b : ℂ) : ℂ :=
∫ (t : ℝ) in 0..1, f ((1 - t) * a + t * b) * (b - a)

/-- The contour integral of a constant `c` along the segment from `a` to `b` is `c * (b - a)`. -/
lemma contour_integral_segment.integral_const (c : ℂ) (a b : ℂ) :
  contour_integral_segment (λ z, c) a b = c * (b - a) :=
by --show_term {
  simp [contour_integral_segment, interval_integral.integral_const] --}

/-- Given a function `f : ℂ → ℂ`, the contour integral of `f` around a triangle is defined to be the
sum of the contour integrals along the three segments forming its sides. -/
def contour_integral (f : ℂ → ℂ) (T : triangle) : ℂ :=
∑ i, contour_integral_segment f (T i) (T (i + 1))

/-- The contour integral of a constant `c` around a triangle is `0`. -/
lemma contour_integral.integral_const (c : ℂ) (T : triangle) : contour_integral (λ z, c) T = 0 :=
begin
  rw contour_integral,
  --rw contour_integral_segment.integral_const,
  simp only [contour_integral, contour_integral_segment.integral_const],
  calc ∑ i, c * (T (i + 1) - T i)
      =  ∑ i, (c * T (i + 1) - c * T i) : _ -- by { congr, ext; ring }
  ... = c * (∑ i, T (i + 1)) - c * (∑ i, T i) : _ -- by simp [mul_sum]
  ... = 0 : _,

  {
    congr,
    ext i,
    ring,
    ring,
  },

  {
    --squeeze_simp [mul_sum],
    simp [mul_sum],
  },


  rw sub_eq_zero,
  congr' 1,



  exact (equiv.add_left (1 : zmod 3)).sum_comp _
end



/-- The function partitioning a triangle into four smaller triangles, parametrized by `ℤ/3ℤ` (one
for each of the three corner triangles) and `none` (for the centre triangle). -/
def quadrisect (T : triangle) : option (zmod 3) → triangle
| none := λ j, ((∑ i, T i) - T j) / 2
| (some i) := λ j, (T i + T j) / 2

/-- The integral of a function over a triangle is the sum of the four subdivided triangles
-/
lemma foo (f : ℂ → ℂ ) (T : triangle ) :
  contour_integral f T = ∑ i, contour_integral f (quadrisect T i)
  :=
begin
  /- Adrian? -/
  sorry,
end


/-- The integral of a function over a triangle is bounded by the maximal of the four subdivided triangles
-/
lemma foo2 (f : ℂ → ℂ ) (T : triangle ) :
  abs (contour_integral f T) ≤
  4 * Sup (set.range (λ i, abs ( contour_integral f (quadrisect T i)))) :=
begin
  /- AK? -/
  sorry,
end

/--  ∫_a^b F' = F(b)-F(a)
-/
lemma foo3 (F: ℂ → ℂ ) (holc: differentiable ℂ F) (a b :ℂ ) :
  contour_integral_segment (deriv F) a b =
  F b - F a :=
begin
  /- Adrian? -/
  sorry,
end


/--  ∫_T F' = 0
-/
lemma foo3a (F: ℂ → ℂ ) (holc: differentiable ℂ F) (T: triangle ) :
  contour_integral (deriv F) T = 0 :=
begin
  /- AK -/
  sorry,
end

def triangle_hull (T: triangle): set ℂ  := convex_hull (set.range T )

def max_side_length (T: triangle ) : ℝ := Sup (set.range (λ i, abs (T (i+1) - T i)))

lemma foo5 (T:triangle )
  (z w : ℂ ) (hz: z ∈  triangle_hull T) (hw: w ∈  triangle_hull T) :
  dist z w ≤ max_side_length T :=
begin
  /- HM -/
  sorry,
end

lemma foo4 (T:triangle ) (i k : zmod 3) (j : option (zmod 3)) :
  abs ( T i -  (quadrisect T j k)) ≤ max_side_length T :=
begin
  /- AK -/
  sorry,
end

lemma foo6 (T:triangle ) (j : option (zmod 3)) :
  max_side_length (quadrisect T j) =
  max_side_length T / 2 :=
begin
  /- AK -/
  sorry,
end

/- NEXT TIME -/

theorem Goursat (f : ℂ →  ℂ ) (holc: differentiable ℂ f) (T₀ : triangle ) :
  contour_integral f T₀  = 0 :=
begin

/-

theorem Goursat (f : ℂ →  ℂ ) (holc: differentiable ℂ f) (T: triangle ) :
  contour_integral f T = 0 :=
begin

  have : ∀ n , ∀ (T' :triangle ) , ∃ (T'' : triangle), -- ∃ j : option (zmod 3) ,
--    T'' = quadrisect T' j ∧
    abs ( contour_integral f T') ≤ 4^n * abs (contour_integral f T'')
    ∧
    max_side_length T'' ≤ 1/4^n * max_side_length T'
    ∧
    convex_hull T'' ⊂ convex_hull T'
    ,
    {
      sorry,
    },
  choose! T_seq  -- i h h' using this,
   H using this,

  let X := λ n, nat.rec_on n T _  _,
    --(λ n T, (T_seq n T) (H n T)),

  sorry,
end
-/

  have : ∀ n , ∀ (T' :triangle ) , ∃ (T'' : triangle), ∃ j : option (zmod 3) ,
    T'' = quadrisect T' j ∧
    abs ( contour_integral f T') ≤ 4^n * abs (contour_integral f T''),
    {
      sorry,
    },
  choose! T   i h h' using this,
   --H using this,

  let X : ℕ → (triangle × ( option (zmod 3))) := λ n, nat.rec_on n ⟨T₀ ,none⟩
   (λ n p, ⟨ T n p.1, i n p.1⟩ ),
    --(λ n T, (T_seq n T) (H n T)),

  let T_seq : ℕ → triangle := λ n, (X n).1,
  let i_seq : ℕ → option (zmod 3) := λ n, (X n).2,

  have diameter : ∀ n m, ∀ i j,
    dist (T_seq n i) (T_seq m j) ≤ max_side_length T₀ / 2^(min n m),
    {

      sorry,
    },

  obtain ⟨ z, hz⟩  : ∃ z , filter.tendsto (λ n, T_seq n 0) filter.at_top (𝓝 z),
  {
    sorry,
  },


  have lim_pt : ∃ z:ℂ , ∀ n, z ∈ triangle_hull (T_seq n),
  {
    use z,
    intros,
    sorry,
  },

  have localize := (holc z).has_deriv_at ,
  rw has_deriv_at_iff_is_o_nhds_zero  at  localize,

  sorry,
end

/--
  |∫_γ f| ≤ ⊔ |f|
-/


/--

  in a neighborhood of z,
  f(w) = f(z) + f'(z) (w-z) + Err

-/
