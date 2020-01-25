<?php

	// NOTE: the freakin check for the file still doesnt work so I'll make it in matlab...

	define("NEW_IMAGE_DIRECTORY",		"upload");
	define("OLD_IMAGE_DIRECTORY",		"requested");

	function returnSuccess($msg) {
		echo $msg;
		die();
	}

	function returnNothing() {
		die();
	}

	function return404() {
		http_response_code(404);
		echo "404";
		die();
	}

	function isJpegValid($fullname) {
		$file = fopen($fullname, 'r');
		if ($file) {
			$o = 1;
			if (fseek($file, -$o, SEEK_END) == 0) {
				do {
					if (fread($file, 1) == "\xFF") {
						if (fread($file,1) == "\xD9") {
							return true;
						} else {
							$o = $o + 2;
						}
					} else {
						$o = $o + 1;
					}
				} while (fseek($file, -$o, SEEK_END) == 0);
			}
		}
		return false;
	}

	if ($_GET['action'] == "getNextImage") {
		
		$files = array_values(array_diff(scandir(NEW_IMAGE_DIRECTORY), array('..', '.')));
		if (count($files) > 0) {
			// At least one new picture is available
			
			// see if one of those pictures is readable (maybe the upload is still in progress)
			foreach ($files as $filename) {
				$fullname = NEW_IMAGE_DIRECTORY . "/" . $filename;
				$fullurl = "http://$_SERVER[HTTP_HOST]/$fullname";
				
				if (isJpegValid($fullname)) {
					break;
				} else {
					$filename = "";
				}
			}
			
			if ($filename != "") {
				// move the file to the old image directory
				$newfullname = OLD_IMAGE_DIRECTORY . "/" . date("Y-m-d_H-i-s") . ".jpg";
				rename($fullname, $newfullname);
				$newurl = "http://$_SERVER[HTTP_HOST]/$newfullname";
				returnSuccess($newurl);
			} else {
				// no valid picture found
				returnNothing();
			}
		} else {
			// No new picture found
			returnNothing();
		}
		
	} else {
		
		return404();
		
	}
?>
