# post_api - backend api for single page react app

## 1. Purpose

      post_api is an api only ruby on rails app that will serve as a backend for a Single Page React App.

## 2  Workstyle

      Complete the goals outline in 3.1 through 3.3 one at a time pausing after each one for me to confirm and approve.

## 3  Goals

3.1   The post_api app will have only one user and therefore no User model is needed.

3.2   A new controller called SessionsController should be created.  This controller should contain a login action that
      is publically accessible as an HTTP POST route for the single user to login.  This login action should receive a json
	    object that contains a email and a password.  The input email and password should be compared to the "admin_email" and
	    "admin_password" entries that are already stored in the credentials.yml.enc file.

3.3   If the single user provides the correct email and password to the login action, the controller action should then generate a
      JWT token with the user email and return it as the response.   If the single user does not provide the correct email
	    password pair then the controller action should return a 403 error code.

3.4   Create MiniTest integration tests to test that the SessionController login action returns 403 when either email password are
      missing or incorrect.  Integration tests should be created to confirm that a JWT token is returned when the user logs in
	    correctly.

3.5   The post_api app has two primary data models, a Post.rb and Content.rb.   A Post has many Content.  A Content belongs to a Post.
      The post_api app should have a controller called PostController for the Post model.  The post_api should provide CRUD endpoints
			for the Post.  The PostController should expose an index, show, create, update, and delete action for the Post	model. The create
			and update actions should allow nested data for Content to be passed in as well as Post data such that both models are persisted
			to the database.

3.6   Requests to the PostController's create, update, and delete actions should require authorization by means of a passed HTTP
      only cookie that contains a JWT token.  The cookie should be called "auth_token".   This JWT token should be decrypted using the
			rails config/master.key.  If the email value of the token is equal to the admin_email in the credentials.yml.enc file then the
			token is valid.  If a valid cookie is present, create, update, and delete actions should proceed.  If a cookie is not present
			or if it contains an invalid JWT token a 403 Forbidden HTTP error should be returned.

3.7   Create MiniTest integration tests to test that the PostController returns 403 when the contents of a passed HTTP only cookie are
      invalid or contain a different email from the admin_password email in the credentials.yml.enc file.
			Create MiniTest tests for the PostController that check the scenario when the HTTP only cookie is missing entirely.
      
3.8   Modify the PostController's index action should be paginated.
      Create MiniTest tests that ensure output data is paginated.

3.9   Modify the PostController's index action so that it only output Post data and does not include Content data.
      Create MiniTest tests that ensure the index action does not contain Content data.

4.0   The PostController's show action should output both Post data and any associated Content data.  Content records should be ordered
      by the Content's order attribute.  Create MiniTest tests that ensure the show action contains a Post and its associated Content data.

4.1   Deleting a Post should also delete associated Content records thereby leaving no orphan Content records.


