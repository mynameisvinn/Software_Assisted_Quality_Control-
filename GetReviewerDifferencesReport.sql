DELIMITER $$

USE `limsdb`$$

DROP PROCEDURE IF EXISTS `GetReviewerDifferencesReport`$$

CREATE DEFINER=`lims`@`%` PROCEDURE `getReviewerDifferencesReport`(IN reviewer1_user_id INT, IN reviewer2_user_id INT,
IN ldata_file_id INT, IN ip_address_and_port VARCHAR(255), IN red_range_top VARCHAR(10), IN green_range_top VARCHAR(10),
IN patch_height INT, IN patch_width INT)
BEGIN
   IF red_range_top IS NULL THEN 
     SET red_range_top = 512;
   END IF;
   IF green_range_top IS NULL THEN 
     SET green_range_top = 512;
   END IF;
   IF patch_height IS NULL THEN
	SET patch_height = 100;
   END IF;
   IF patch_width IS NULL THEN
	SET patch_width = 100;
   END IF; 
SELECT CONCAT('<html><body><h1>Data File Id: ', ldata_file_id, '</h1><table border=1>') html
UNION ALL
SELECT DISTINCT CONCAT('<tr><td>user_id: ', reviewer2, ', tile_id: ', tile_id, '</td><td>', url_red, '</td><td>', url_green, '</td></tr>') url
FROM (
SELECT
'reviewer1' AS reviewer1, c.id click_id, tile_id, click_location_x_coordinate r1x, click_location_y_coordinate r1y, 
CONCAT('<img src="http://', ip_address_and_port, '/adore-djatoka/resolver?url_ver=Z39.88-2004&rft_id=http://', ip_address_and_port, '/static/images/sample_images/', primary_file_system_location_lossy, '&svc_id=info:lanl-repo/svc/getRegion&svc_val_fmt=info:ofi/fmt:kev:mtx:jpeg2000&svc.format=image/jpeg&svc.level=9&svc.rotate=0&svc.region=', click_location_y_coordinate - ROUND(patch_height / 2), ',', click_location_x_coordinate - ROUND(patch_width / 2), ',', patch_height + 1, ',', patch_width + 1, '&svc.crange=0-',red_range_top,',0-0,0-0&svc.gamma=1">') AS url_red,
CONCAT('<img src="http://', ip_address_and_port, '/adore-djatoka/resolver?url_ver=Z39.88-2004&rft_id=http://', ip_address_and_port, '/static/images/sample_images/', primary_file_system_location_lossy, '&svc_id=info:lanl-repo/svc/getRegion&svc_val_fmt=info:ofi/fmt:kev:mtx:jpeg2000&svc.format=image/jpeg&svc.level=9&svc.rotate=0&svc.region=', click_location_y_coordinate - ROUND(patch_height / 2), ',', click_location_x_coordinate - ROUND(patch_width / 2), ',', patch_height + 1, ',', patch_width + 1, '&svc.crange=0-0,0-', green_range_top, ',0-0&svc.gamma=1">') AS url_green
FROM 
data_file_click c,
data_file d
WHERE 1
AND d.id = c.data_file_id
AND user_id = reviewer1_user_id
AND data_file_id = ldata_file_id ) reviewer1,
(
SELECT
'reviewer2' AS reviewer2, click_location_x_coordinate r2x, click_location_y_coordinate r2y
FROM 
data_file_click c,
data_file d
WHERE 1
AND d.id = c.data_file_id
AND user_id = reviewer2_user_id
AND data_file_id = ldata_file_id) reviewer2
GROUP BY reviewer1, r1x, r1y
HAVING MIN(ROUND(SQRT( ((r1x - r2x) * (r1x - r2x)) + ((r1y - r2y) * (r1y - r2y)))))  > 40
UNION ALL
SELECT DISTINCT CONCAT('<tr><td>user_id: ', reviewer2, ', tile_id: ', tile_id, '</td><td>', url_red, '</td><td>', url_green, '</td></tr>') url
FROM (
SELECT
'reviewer2' AS reviewer2, c.id click_id, click_location_x_coordinate r2x, click_location_y_coordinate r2y, tile_id,
CONCAT('<img src="http://', ip_address_and_port, '/adore-djatoka/resolver?url_ver=Z39.88-2004&rft_id=http://', ip_address_and_port, '/static/images/sample_images/', primary_file_system_location_lossy, '&svc_id=info:lanl-repo/svc/getRegion&svc_val_fmt=info:ofi/fmt:kev:mtx:jpeg2000&svc.format=image/jpeg&svc.level=9&svc.rotate=0&svc.region=', click_location_y_coordinate - ROUND(patch_height / 2), ',', click_location_x_coordinate - ROUND(patch_width / 2), ',', patch_height + 1, ',', patch_width + 1, '&svc.crange=0-', red_range_top, ',0-0,0-0&svc.gamma=1">') AS url_red,
CONCAT('<img src="http://', ip_address_and_port, '/adore-djatoka/resolver?url_ver=Z39.88-2004&rft_id=http://', ip_address_and_port, '/static/images/sample_images/', primary_file_system_location_lossy, '&svc_id=info:lanl-repo/svc/getRegion&svc_val_fmt=info:ofi/fmt:kev:mtx:jpeg2000&svc.format=image/jpeg&svc.level=9&svc.rotate=0&svc.region=', click_location_y_coordinate - ROUND(patch_height / 2), ',', click_location_x_coordinate - ROUND(patch_width / 2), ',', patch_height + 1, ',', patch_width + 1, '&svc.crange=0-0,0-', green_range_top, ',0-0&svc.gamma=1">') AS url_green
FROM 
data_file_click c,
data_file d
WHERE 1
AND d.id = c.data_file_id
AND user_id = reviewer2_user_id
AND data_file_id = ldata_file_id) reviewer2,
(
SELECT
'reviewer1' AS reviewer1, click_location_x_coordinate r1x, click_location_y_coordinate r1y
FROM 
data_file_click c,
data_file d
WHERE 1
AND d.id = c.data_file_id
AND user_id = reviewer1_user_id
AND data_file_id = ldata_file_id) reviewer1
GROUP BY reviewer2, r2x, r2y
HAVING MIN(ROUND(SQRT( ((r1x - r2x) * (r1x - r2x)) + ((r1y - r2y) * (r1y - r2y)))))  > 40
UNION ALL
SELECT '<zzz></zzz></table></body></html'
ORDER BY 1;
 END$$

DELIMITER ;