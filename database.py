#!/usr/bin/python

import MySQLdb

# Open database connection
host="limsdb.ceqbf5x8nxxx.us-east-1.rds.amazonaws.com"
username="lims"
password="mou53Brains!"
database="limsdb"


def getMagnificationLevel():
	db = MySQLdb.connect(host,username,password,database )

	# prepare a cursor object using cursor() method
	cursor = db.cursor()
	
	sql="""SELECT magnification_level FROM data_file_viewer_default_grid_depth"""
  	cursor.execute(sql)
   	results = cursor.fetchall()
   	magnification_level=-1
   	for row in results:
      		magnification_level = row[0]
	db.close()
	return magnification_level



def getTileId(clickX, clickY, imageW, imageH, imageLevels, magnificationLevel):
	# Tile height and width and, therefore, size is fixed and hard-coded into the function.  It's just that some tiles are not completely full of image data.  So, the function will give you the correct tile.  It just might not be a complete tile.
	tileW = 1570
	tileH = 748 
 
	#1 - Set correct magnification level
	# magnificationLevel = (magnificationLevel <= 0 || magnificationLevel > imageLevels) ? imageLevels : magnificationLevel
 
	#2 - Calculate new tileW and tileH
	# tileW = (int)(tileW * Math.Pow(2, imageLevels - magnificationLevel));
	# tileH = (int)(tileH * Math.Pow(2, imageLevels - magnificationLevel));
 
	#3 - Get number of tiles per row
	# cntTileX = (int)Math.Ceiling((double)imageW / tileW);
 
	#4 - Get tile number
	# xNum = (int)Math.Floor((double)clickX / tileW);
	# yNum = (int)Math.Floor((double)clickY / tileH);
	# result = xNum + yNum * cntTileX + 1;
 
	# return result;
	return -1



def insertClick(counter, x_coordinate, y_coordinate, lossy_jp2_file_name, image_height, image_width, image_levels, magnification_level):
	db = MySQLdb.connect(host,username,password,database )

	# prepare a cursor object using cursor() method
	cursor = db.cursor()
	
	# execute SQL query using execute() method.
	cursor.execute("SELECT VERSION()")
	
	# Fetch a single row using fetchone() method.
	data = cursor.fetchone()
	
	print "Database version : %s " % data
	
	
	
	try:
   		sql_annotation_radius="""SELECT annotation_circle_radius_in_pixels from data_file_annotation_circle_defaults LIMIT 1"""
   		cursor.execute(sql_annotation_radius)
   		results = cursor.fetchall()
   		annotation_radius=-1
   		for row in results:
      			annotation_radius = row[0]

		#####
		# Hard-code to 1 because the alpha is not being looked up properly 
   		sql_tmr_a_bungarotoxin="""SELECT id FROM counter WHERE counter_name = 'TMR-a-Bungarotoxin' LIMIT 1"""
   		cursor.execute(sql_tmr_a_bungarotoxin)
   		results = cursor.fetchall()
   		tmr_a_bungarotoxin=1
   		for row in results:
      			tmr_a_bungarotoxin = row[0]

   		sql_vacht="""SELECT id FROM counter WHERE counter_name = 'VACHT' LIMIT 1"""
   		cursor.execute(sql_vacht)
   		results = cursor.fetchall()
   		vacht=-1
   		for row in results:
      			vacht = row[0]
		if (counter == 'VACHT'):
			print "VACHT\n"
			counter_id = vacht
		else:
			print "Bungarotoxin\n"
			counter_id = tmr_a_bungarotoxin
		#####


		sql_data_file_id="SELECT id FROM data_file WHERE primary_file_system_location_lossy=%s"
   		cursor.execute(sql_data_file_id,lossy_jp2_file_name)
   		results = cursor.fetchall()
   		data_file_id=-1
   		for row in results:
      			data_file_id= row[0]

		sql_user_id="SELECT id FROM auth_user WHERE username='system'"
   		cursor.execute(sql_user_id)
   		results = cursor.fetchall()
   		user_id=-1
   		for row in results:
      			user_id= row[0]


		#Hard-code to 1 for now
		analytical_protocol_counter_set_id = 1
		#sql_analytical_protocol_counter_set_id=""" """"
   		#cursor.execute(sql_analytical_protocol_counter_set_id)
   		#results = cursor.fetchall()
   		#analytical_protocol_counter_set_id=-1
   		#for row in results:
			#analytical_protocol_counter_set_id = row[0]


		#***** Need to replace with actual tile id:
		tile_id=getTileId(x_coordinate, y_coordinate, image_width, image_height, image_levels, magnification_level)



		sql="""INSERT INTO data_file_click 
			(user_id, data_file_id, analytical_protocol_counter_set_id, 
			tile_id, click_location_x_coordinate, click_location_y_coordinate, 
			annotation_circle_radius_in_pixels, counter_id, 
			yes_count, maybe_count, create_time, last_changed_time)
			VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 1, 0, NOW(), NOW())""" % (user_id,data_file_id, analytical_protocol_counter_set_id, tile_id, x_coordinate, y_coordinate, annotation_radius, counter_id )
		print sql
		cursor.execute(sql)
		db.commit()
	except (MySQLdb.OperationalError, MySQLdb.ProgrammingError), e:
    		raise e


	# disconnect from server
	db.close()

x_coordinate=123123
y_coordinate=2343
lossy_jp2_file_name="16_6_2015-02-05-09-20-00_3_483_-_2015-02-16_07.18.32_4_lossy.jp2"
counter='VACHT'
#**** You need to get image levels from the image.  For our data, it will probably always be 8:
image_levels = 8

#**** You need to get the image height and width from the image:
image_width=3
image_height=10
magnification_level = getMagnificationLevel()
insertClick(counter, x_coordinate, y_coordinate, lossy_jp2_file_name, image_height, image_width, image_levels, magnification_level)
