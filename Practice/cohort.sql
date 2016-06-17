DROP TEMPORARY TABLE IF EXISTS first_rental;

CREATE TEMPORARY TABLE first_rental
SELECT
   customer_id,
   MIN(rental_date) "first_rental_date"
FROM rental
GROUP BY customer_id
;

DROP TEMPORARY TABLE IF EXISTS cohort_size;

CREATE TEMPORARY TABLE cohort_size
SELECT
	LEFT(first_rental_date, 7) month,
	COUNT(*) num
FROM first_rental
GROUP BY month
;

DROP TEMPORARY TABLE IF EXISTS middle_step;

CREATE TEMPORARY TABLE middle_step
SELECT
	r.*,
	fr.first_rental_date cohort,
	p.amount amount,
	cs.num cohort_size
FROM rental r
	JOIN payment p 
	  ON p.rental_id = r.rental_id
	JOIN first_rental fr 
	  ON r.customer_id = fr.customer_id
	JOIN cohort_size cs
	  ON LEFT(fr.first_rental_date, 7) = cs.Month
;



# 코호트를 기준으로 # 렌탈 데이트 로 그룹바이 한것
DROP TEMPORARY TABLE IF EXISTS cohort;

CREATE TEMPORARY TABLE cohort
SELECT
	date_format(ms.cohort, "%Y%m") cohort_date,
	date_format(rental_date, "%Y%m") rental_date,
	#cohort,
	#LEFT(rental_date, 7) rental_month,
	cohort_size,
	SUM(amount) revenue,
	SUM(amount)/cohort_size RPU
FROM middle_step ms
GROUP BY 1, 2
;

# MONTH AFTER JOIN 뽑기 ==> 빼기함수
SELECT
	cohort_date,
	PERIOD_DIFF(rental_date, cohort_date) months_after_first_rental,
	cohort_size,
	revenue,
	RPU
FROM cohort
ORDER BY cohort_date, months_after_first_rental
;