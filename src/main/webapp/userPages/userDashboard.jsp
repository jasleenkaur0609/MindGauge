<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.lang.*, dao.Test"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Dashboard</title>
<style>
body {
	font-family: Arial, sans-serif;
	margin: 0;
	padding: 0;
	background-color: #EDF6F9;
}

header {
	background-color: #006D77;
	color: #fff;
	padding: 15px 20px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

header h1 {
	margin: 0;
	color: #FFDDD2;
}

.header-buttons {
	display: flex;
	align-items: center;
}

.header-buttons a {
	color: #FFF;
	text-decoration: none;
	padding: 8px 15px;
	margin-left: 15px;
	background-color: #83C5BE;
	border-radius: 5px;
	transition: background-color 0.3s ease;
}

.header-buttons a:hover {
	background-color: #FFDDD2;
	color: #006D77;
}

.container {
	background-color: #FFFFFF;
	width: 80vw;
	margin: 80px auto 20px;
	padding: 30px;
	border-radius: 10px;
	color: #006D77;
	box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
	display: flex;
	flex-wrap: wrap;
	justify-content: space-around;
}

.card {
	background-color: #f9f9f9;
	border: 1px solid #ddd;
	border-radius: 10px;
	box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
	margin: 15px;
	padding: 20px;
	width: calc(30% - 40px); /* Adjust width as needed */
	text-align: center;
}

.card h3 {
	color: #006D77;
}

.card button {
	padding: 8px 15px;
	background-color: #FFDDD2;
	color: #006D77;
	font-size: 13px;
	border: none;
	border-radius: 5px;
	cursor: pointer;
	transition: background-color 0.3s ease;
}

.card button:hover {
	background-color: #E29578;
}

#displaymsg {
	font-size: 18px;
	color: #E29578;
	text-align: center;
}
</style>
</head>
<body>
	<%
	HttpSession session2 = request.getSession(false);
	if (session2 != null && session2.getAttribute("user_id") != null) {
		int user_id = (int) session2.getAttribute("user_id");
		String name = (String) session2.getAttribute("name");
		ArrayList<Test> tests = (ArrayList<Test>) request.getAttribute("tests");
		ArrayList<String> allTopics = (ArrayList<String>) request.getAttribute("allTopics");
		ArrayList<String> allLang = (ArrayList<String>) request.getAttribute("allLang");
	%>

	<header>
		<h1>Welcome, <%=name%>!</h1>
		<div class="header-buttons">
			<a href="/MindGauge/UserProfile">My Profile</a> 
			<a href="/MindGauge/Logout" onclick="return confirmLogout();" class="logout-btn">Logout</a>
		</div>
	</header>

	<div class="container">
		<h2>Take Your Test</h2>
		
		<div style="margin-bottom: 10px;">
			<form action="/MindGauge/FilterTest" method="post">
				<input type="hidden" id="person" name="person" value="user">
				<label for="languageSelect">Select Language:</label> 
				<select id="languageSelect" name="languageSelect">
					<option value="all" selected>All</option>
					<% for(String lang: allLang) { %>
						<option value="<%= lang %>"><%= lang %></option>
					<% } %>
				</select> 
				<label for="topicSelect" style="margin-left: 10px;">Select Topic:</label> 
				<select id="topicSelect" name="topicSelect">
					<option value="all" selected>All</option>
					<% for(String topic: allTopics) { %>
						<option value="<%= topic %>"><%= topic %></option>
					<% } %>
				</select>
				<label for="DifficultyLevel" style="margin-left: 10px;">Select Difficulty Level:</label> 
				<select id="DifficultyLevel" name="DifficultyLevel">
					<option value="all" selected>All</option>
					<option value="easy">Easy</option>
					<option value="medium">Medium</option>
					<option value="hard">Hard</option>
				</select>

				<button class="btn" onclick="searchTests()" style="background-color: #006D77; color: #ffffff; padding: 10px 20px; border: none; border-radius: 5px; opacity: 0.6; margin-left:15px">Search</button>
			</form>
		</div>
		
		<%
		if (tests.size() != 0) {
		%>
		
		<%
			for (Test test : tests) {
		%>
			<div class="card">
				<h3><%= test.getTestTag() %></h3>
				<p><strong>No of Questions:</strong> <%= test.getNoOfQuestions() %></p>
				<p><strong>Language:</strong> <%= test.getLang() %></p>
				<p><strong>Topic:</strong> <%= test.getTopic() %></p>
				<p><strong>Difficulty Level:</strong> <%= test.getLevel() %></p>
				<button onclick="showTestInstructions(<%= test.getTestId() %>, <%= test.getNoOfQuestions() %>)">Take Test</button>
			</div>
		<%
			}
		%>
		<%
		} else {
		%>

		<p id="displaymsg">No tests available.</p>

		<%
		}
		%>
	</div>

	<%
	} else {
		response.sendRedirect("/MindGauge/userPages/userLogin.jsp");
	}
	%>

<div id="testInstructionsModal" class="modal" style="display: none; position: fixed; z-index: 1; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0, 0, 0, 0.6); padding-top: 60px;">
    <div class="modal-content" style="background-color: #EDF6F9; margin: 5% auto; padding: 30px; border: 1px solid #888; width: 80%; border-radius: 15px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);">
        <span class="close-button" onclick="closeTestInstructionsModal()" style="color: #E29578; float: right; font-size: 28px; font-weight: bold; cursor: pointer;">&times;</span>
        <h2 style="color: #006D77; padding: 0 15px 20px 15px; border-bottom: 2px solid #83C5BE; margin-bottom: 20px;">Test Instructions</h2>
        <ul id="testInstructionsList" style="display: flex; flex-direction: column; gap: 15px;">
            
        </ul>
        <label style="display: block; margin-top: 20px; color: #006D77; font-size: 14px;">
            <input type="checkbox" id="termsAndConditionsCheckbox" style="margin-right: 10px;"> 
            I have read and agreed with the terms and conditions provided.
        </label>
        <button class="btn" id="takeTestButton" disabled style="background-color: #006D77; color: #ffffff; padding: 12px 25px; border: none; border-radius: 5px; margin-top: 15px; opacity: 0.6; cursor: pointer;">Take Test</button>
    </div>
</div>


	<script>

   
    function generateTestInstructions() {
        const instructions = [
            "You must maintain a professional and ethical conduct throughout the test.",
        	"Avoid any external aids or resources while taking the test to maintain integrity.",
        	"Double-check your answers before submitting to ensure accuracy.",
            "Please ensure that you grant access to your webcam for the test.",
            "You are required to take the test in fullscreen mode.",
            "Excessive switching between tabs during the test will result in failure.",
			"Notify the administrator immediately if you encounter any technical issues.",
			"Double-check your answers before submitting to ensure accuracy.",
			"Respect the confidentiality and security of the test content."
        ];
        return instructions;
    }   
   
    function showTestInstructions(testId, quesNum) {

    	const testInstructions = generateTestInstructions();

        const modal = document.getElementById("testInstructionsModal");
        const instructionsList = document.getElementById("testInstructionsList");
        instructionsList.innerHTML = "";

        testInstructions.forEach(instruction => {
            const li = document.createElement("li");
            li.textContent = instruction;
            instructionsList.appendChild(li);
        });

        modal.style.display = "block";

        const termsCheckbox = document.getElementById("termsAndConditionsCheckbox");
        const takeTestButton = document.getElementById("takeTestButton");

        termsCheckbox.addEventListener("change", () => {
            takeTestButton.disabled = !termsCheckbox.checked;
        });
        
        document.getElementById("takeTestButton").addEventListener("click", ()=>{
        	document.requestFullscreen()
        	.then(()=>{ startTest(testId, quesNum) })
        	.catch((e) => console.log(e));
        })

       	takeTestButton.addEventListener("click", () => {
            startTest(testId, quesNum);
        });
    }
   
    //-----------------------------------------------------------------------------------

    function closeTestInstructionsModal() {
        document.getElementById("testInstructionsModal").style.display = "none";
    }

    function startTest(testId, quesNum) {
        window.location.href = "/MindGauge/TestLive?test_id=" + testId + "&ques_num=" + quesNum;
    }

    function confirmLogout() {
        return confirm("Do you want to log out?");
    }
	
	document.addEventListener("dblclick", ()=>{
		document.documentElement.requestFullscreen()
        .then(() => {
            console.log("Full-screen mode enabled.");
        })
        .catch((e) => console.log("Error enabling full-screen mode:", e));
	})
</script>
</body>
</html>
