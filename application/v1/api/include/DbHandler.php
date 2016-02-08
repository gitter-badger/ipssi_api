<?php

/**
 * Class to handle all db operations
 * This class will have CRUD methods for database tables
 *
 * @author Ravi Tamada
 * @link URL Tutorial link
 */
include ("php_mailer/PHPMailerAutoload.php");

class DbHandler {

    private $conn;

    function __construct() {
      /*  require_once dirname(__FILE__) . '/DbConnect.php';
        // opening db connection
        $db = new DbConnect();
        $this->conn = $db->connect();*/
    }


    //Recupere le json du marché


    public function json_marcher() {


        $json = file_get_contents('https://download.data.grandlyon.com/ws/grandlyon/gin_nettoiement.ginmarche/all.json');
        $obj = ($json);


        return $obj;

     //   echo $obj->access_token;exit;




    }




    public function getApiKeyById($user_id) {
        $stmt = $this->conn->prepare("SELECT api_key FROM users WHERE id = ?");
        $stmt->bind_param("i", $user_id);
        if ($stmt->execute()) {
            // $api_key = $stmt->get_result()->fetch_assoc();
            // TODO
            $stmt->bind_result($api_key);
            $stmt->close();
            return $api_key;
        } else {
            return NULL;
        }
    }



    /**
     * Validating user api key
     * If the api key is there in db, it is a valid key
     * @param String $api_key user api key
     * @return boolean
     */
    public function isValidApiKey($api_key) {
//        $stmt = $this->conn->prepare("SELECT idToken from Token WHERE value = ?");
//        $stmt->bind_param("s", $api_key);
//        $stmt->execute();
//        $stmt->store_result();
//        $num_rows = $stmt->num_rows;
//        $stmt->close();
//        return $num_rows > 0;


   // print_r($api_key);exit;

          if($api_key == 'DYhG93b0qyJfIxfs2guVoUurrFGHrgr458ds0FgaC9mi' )
              return 1;
          else
              return 0;
                  
    }

    /**
     * Generating random Unique MD5 String for user Api key
     */
    private function generateApiKey() {
        return md5(uniqid(rand(), true));
    }



}

?>
