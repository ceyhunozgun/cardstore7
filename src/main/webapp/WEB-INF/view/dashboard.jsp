<!DOCTYPE html>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<html>
 <head>
  <style>

.dashboard-page {
  width: 360px;
  padding: 1% 0 0;
}
.form {
  position: relative;
  z-index: 1;
  background: #FFFFFF;
  max-width: 360px;
  margin: 10px;
  padding: 10px ;
  text-align: center;
  box-shadow: 0 0 20px 0 rgba(0, 0, 0, 0.2), 0 5px 5px 0 rgba(0, 0, 0, 0.24);
}
.form input {
  font-family: "Tahoma", sans-serif;
  outline: 0;
  background: #f2f2f2;
  width: 100%;
  border: 0;
  margin: 0 0 15px;
  padding: 15px;
  box-sizing: border-box;
  font-size: 14px;
}
.form button {
  font-family: "Tahoma", sans-serif;
  outline: 0;
  background: #4CAF50;
  width: 100%;
  border: 0;
  padding: 15px;
  color: #FFFFFF;
  font-size: 14px;
  -webkit-transition: all 0.3 ease;
  transition: all 0.3 ease;
  cursor: pointer;
}
.form button:hover,.form button:active,.form button:focus {
  background: #43A047;
}
.form .message {
  margin: 15px 0 0;
  color: #b3b3b3;
  font-size: 12px;
}
.form .message a {
  color: #4CAF50;
  text-decoration: none;
}
.container {
  position: relative;
  z-index: 1;
  max-width: 300px;
  margin: 0 auto;
}
.container:before, .container:after {
  content: "";
  display: block;
  clear: both;
}
.container .info {
  margin: 50px auto;
  text-align: center;
}
.container .info h1 {
  margin: 0 0 15px;
  padding: 0;
  font-size: 36px;
  font-weight: 300;
  color: #1a1a1a;
}
.container .info span {
  color: #4d4d4d;
  font-size: 12px;
}
.container .info span a {
  color: #000000;
  text-decoration: none;
}
.container .info span .fa {
  color: #EF3B3A;
}
body {
  background: #76b852; /* fallback for old browsers */
  background: -webkit-linear-gradient(right, #76b852, #8DC26F);
  background: -moz-linear-gradient(right, #76b852, #8DC26F);
  background: -o-linear-gradient(right, #76b852, #8DC26F);
  background: linear-gradient(to left, #76b852, #8DC26F);
  font-family: "Roboto", sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;      
}

table {
	background-color: black;
}

th {
	background-color: lightgray;
}

td {
	background-color: white;
	padding: 5px;
}
  </style>
  <script>
  // Builds the HTML Table out of list.
  function buildHtmlTable(list, columnList, selector, actionHeader, handlerName) {
	 $(selector).empty();
	 
    addAllColumnHeaders(columnList, selector, actionHeader);

    for (var i = 0; i < list.length; i++) {
      var row$ = $('<tr/>');
      for (var colIndex = 0; colIndex < columnList.length; colIndex++) {
        var cellValue = list[i][columnList[colIndex]];
        if (cellValue == null) cellValue = "";
        row$.append($('<td/>').html(cellValue));
      }
      row$.append($('<td>&nbsp;</td>'));
      row$.append($('<td><button onclick="' + handlerName + '(' + i + ')">O</button></td>'));
      $(selector).append(row$);
    }
  }

  // Adds a header row to the table and returns the set of columns.
  // Need to do union of keys from all records as some records may not contain
  // all records.
  function addAllColumnHeaders(columns, selector, actionHeader) {
    var headerTr$ = $('<tr/>');

    for (var i = 0; i < columns.length; i++) {
       headerTr$.append($('<th/>').html(columns[i]));
    }
    headerTr$.append($('<th/>').html("&nbsp;"));
    headerTr$.append($('<th/>').html(actionHeader));
    $(selector).append(headerTr$);
  }
  
  function convertFormToJSON(form){
	    var array = jQuery(form).serializeArray();
	    var json = {};
	    
	    jQuery.each(array, function() {
	        json[this.name] = this.value || '';
	    });
	    
	    return json;
   }
 
  
	function handleBuyCardResponse(name, res) {
		if (res.error)
			alert("Can't buy card " + name + '. Error: ' + res.error);
		else {
			alert('Card ' + name + ' bought successfully. Your current balance is ' + res.newBalance);
			$("#balance").html(res.newBalance);
		}
	}
	function buyCard(owner, name) {
	   $.ajax({
		   type: "POST",
		   url: "buy",
		   data: JSON.stringify({owner:owner, name: name}),
		   success: function(data){handleBuyCardResponse(name, data);},
		   dataType: "json",
		   contentType : "application/json"
		 });
   }
   function buyCardClicked(idx) {
	   var owner = $('#insale-cards-table')[0].childNodes[idx+1].childNodes[2].innerText;
	   var name = $('#insale-cards-table')[0].childNodes[idx+1].childNodes[0].innerText;
	   var price = $('#insale-cards-table')[0].childNodes[idx+1].childNodes[3].innerText;
	   
	   if (confirm("Are you sure to buy the card " + name + " at the price " + price + " ?"))
		   buyCard(owner, name);
   } 

  function handleSellCardResponse(name, res) {
	   if (res)
		   alert('Card ' + name + ' marked as OnSale successfully.');
	   else
		   alert("Can't mark card " + name + ' as OnSale.');
   }
   function sellCard(name, price) {
	   $.ajax({
		   type: "POST",
		   url: "sell",
		   data: JSON.stringify({name:name, price: price}),
		   success: function(data){handleSellCardResponse(name, data);},
		   dataType: "json",
		   contentType : "application/json"
		 });
   }
   function sellCardClicked(idx) {
	   var name = $('#my-cards-table')[0].childNodes[idx+1].childNodes[0].innerText;
	   var price = window.prompt("Please enter the sell price for the card " + name, "10")
	   sellCard(name, price);
   } 
   
   function showMyCards(res) {
	   buildHtmlTable(res, ['name', 'dateLoaded'], '#my-cards-table', 'Sell', 'sellCardClicked');
   }
   function showInSaleCards(res) {
	   buildHtmlTable(res, ['name', 'dateLoaded', 'owner', 'price'], '#insale-cards-table', 'Buy', 'buyCardClicked');
   }
   function listCards(inSale) {
	   $.ajax({
		   type: "GET",
		   url: "cards?inSale=" + inSale,
		   success: function(data){if (inSale) { showInSaleCards(data)} else { showMyCards(data);}},
		   dataType: "json",
		   contentType : "application/json"
		 });
   }

   function handleAddCardResponse(card) {
	   alert('Card ' + card.name + ' added successfully.');
	   $("#add-card-form")[0].reset();
	   $("#add-card-form-div").hide();
   }
   function addCard() {
	   var formData = convertFormToJSON($("#add-card-form"));
	   $.ajax({
		   type: "POST",
		   url: "cards",
		   data: JSON.stringify(formData),
		   success: function(data){handleAddCardResponse(data);},
		   dataType: "json",
		   contentType : "application/json"
		 });
   }
   function addCardClicked() {
	   $("#add-card-form-div").show(); 
	   $("#my-cards-table-div").hide(); 
	   $("#insale-cards-table-div").hide();
   }
   
   function listMyCards() {
	   $("#add-card-form-div").hide(); 
	   $("#my-cards-table-div").show(); 
	   $("#insale-cards-table-div").hide();
	   listCards(false);
   }
   function listInSaleCards() {
	   $("#add-card-form-div").hide(); 
	   $("#my-cards-table-div").hide(); 
	   $("#insale-cards-table-div").show();
	   listCards(true);
   }
   
   function logout() {
	   $.ajax({
		   type: "POST",
		   url: "logout",
		   success: function(data){ window.location.reload(); },
		   dataType: "json",
		   contentType : "application/json"
		 });
   }
  </script>
 </head>
 <body>
	<div class="dashboard-page">
		<span><b>Welcome ${user.name}</b></span>
		<br/>
		<span>Balance</span>
		<span id="balance"><b>${user.balance}</b></span>
		<br/>
		<br/>
		<div>
			<button onclick="addCardClicked()">Add Card</button>
			<button onclick="listMyCards()">My Cards</button>
			<button onclick="listInSaleCards()">On Sale Cards</button>
			&nbsp;
			&nbsp;
			<button onclick="logout()">Logout</button>
		</div>
		<br/>
		<br/>
		<div id="add-card-form-div" style="display:none">
			<form id="add-card-form" onsubmit="return false;"> 
				<input type="text" name="name" placeholder="name" /> 
				<button onclick="addCard()">Add</button>
			</form>
		</div>
		<div id="my-cards-table-div">
			<table id="my-cards-table" cellspacing=1 cellpadding=2>
			</table>
		</div>
		<div id="insale-cards-table-div">
			<table id="insale-cards-table" cellspacing=1 cellpadding=2>
			</table>
		</div>
	</div>
	
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.js"></script>
</body>
</html>
