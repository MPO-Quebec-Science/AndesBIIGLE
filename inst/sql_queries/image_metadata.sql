SELECT 
	shared_models_image.image as filename,
-- 	shrimp_refcatch.aphia_id,
-- 	shrimp_refcatch.scientific_name,
-- 	shrimp_refcatch.common_name_en,
-- 	shrimp_refcatch.common_name_fr,
-- 	shrimp_refcatch.code AS strap_code,
	shared_models_sample.sample_number AS set_number,
	shared_models_station.name AS station_name,
	shared_models_sample.start_latitude,
	shared_models_sample.start_longitude,
	CASE 
	WHEN shared_models_image.type="shrimp_catch" THEN shrimp_refcatch.aphia_id
  	WHEN shared_models_image.type="shrimp_sampling" THEN shrimpsampling_refcatch.aphia_id
	ELSE refcatch.aphia_id
	END as aphia_id,
    CASE 
	WHEN shared_models_image.type="shrimp_catch" THEN shrimp_refcatch.scientific_name
  	WHEN shared_models_image.type="shrimp_sampling" THEN shrimpsampling_refcatch.scientific_name
	ELSE refcatch.scientific_name
	END as scientific_name,
    CASE 
	WHEN shared_models_image.type="shrimp_catch" THEN shrimp_refcatch.common_name_en
  	WHEN shared_models_image.type="shrimp_sampling" THEN shrimpsampling_refcatch.common_name_en
	ELSE refcatch.common_name_en
	END as common_name_en,
	CASE 
	WHEN shared_models_image.type="shrimp_catch" THEN shrimp_refcatch.common_name_fr
  	WHEN shared_models_image.type="shrimp_sampling" THEN shrimpsampling_refcatch.common_name_fr
	ELSE refcatch.common_name_fr
	END as common_name_fr,
	CASE 
	WHEN shared_models_image.type="shrimp_catch" THEN shrimp_refcatch.code
  	WHEN shared_models_image.type="shrimp_sampling" THEN shrimpsampling_refcatch.code
	ELSE refcatch.code
	END as strap_code
FROM shared_models_image
LEFT JOIN shared_models_sample
ON shared_models_image.sample_id=shared_models_sample.id
LEFT JOIN shrimps_shrimpcatch
ON shared_models_image.shrimp_catch_id=shrimps_shrimpcatch.id
LEFT JOIN shared_models_referencecatch shrimp_refcatch
ON shrimps_shrimpcatch.reference_catch_id = shrimp_refcatch.id
LEFT JOIN shrimps_shrimpsampling
ON shared_models_image.shrimp_sampling_id=shrimps_shrimpsampling.id
LEFT JOIN shared_models_referencecatch shrimpsampling_refcatch
ON shrimps_shrimpsampling.reference_catch_id = shrimpsampling_refcatch.id
LEFT JOIN shared_models_catch
ON shared_models_image.catch_id=shared_models_catch.id
LEFT JOIN shared_models_referencecatch refcatch
ON shared_models_catch.reference_catch_id = refcatch.id
LEFT JOIN shared_models_station
ON shared_models_sample.station_id = shared_models_station.id
LEFT JOIN shared_models_mission
ON shared_models_mission.id = shared_models_sample.mission_id
/*  need to filter by active mission, this should be done in the R function */
/* WHERE shared_models_mission.is_active=1 */
/*  need to filter by complete images only */
/* WHERE shared_models_image.complete=1 */
