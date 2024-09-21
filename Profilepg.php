<?php
include "Connection.php";
include "SessionPG.php";
$username = $_SESSION['username'];
$sql = "SELECT Firstname, Lastname, Phone, email from users2";
