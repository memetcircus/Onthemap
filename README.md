# onthemap  
  
The On The Map app allows users to share their location and a URL with their fellow students of the Udacity's the *iOS Nanodegree program*. To visualize this data, On The Map uses a map with pins for location and pin annotations for student names and URLs, allowing students to place themselves “on the map,” so to speak.
First, the user logs in to the app using their Udacity username and password. After login, the app downloads locations and links previously posted by other students. These links can point to any URL that a student chooses.
After viewing the information posted by other students, a user can post their own location and link. The locations are specified with a string and forward geocoded. They can be as specific as a full street address or as generic as “New Orleans” or “Mountain View, SF.”
The app has three view controller scenes:  

* **Login View**: Allows the user to log in using their *Udacity credentials* or using their *Facebook account* or *TouchID*
* **Map and Table Tabbed View**: Allows users to see the locations of other students in two formats.  
* **Information Posting View:** Allows the users specify their own locations and links.  
These three scenes are described in detail below.  
  
####Login View  
The **login view** accepts the email address and password that students use to login to the Udacity site. When the user taps the Login button, the app attempts to authenticate with Udacity’s servers. Clicking on the Sign Up link opens Safari to the Udacity sign-in page.
If the connection is made and the email and password are good, the app segues to the **Map and Table Tabbed View**.  
If the login does not succeed, the user is presented with an alert view specifying whether it was a failed network connection, or an incorrect email and password.
The user also could be authenticated with Facebook. Authentication with Facebook can be occurred through the device’s accounts or through Facebook’s website pressing “Sign in with Facebook” button in the **Login View**.  
Moreover, the user could be also authenticated using his/her saved **TouchID**.The base logic works like; Firstly, the app checks whether a **TouchID** hardware exists or passcode was set. Then if it passes, it looks for a saved username and password data. The username is stored in *NSUserdefaults*. The password data is stored as an encrypted fashion in the keychain. It uses [SSKeychain.m](https://github.com/soffes/sskeychain4) to achieve encryption.
If there is no saved data, it alerts to enter password and username into the logon text fields. After a successful login, the user data is stored on the device and touch ID is activated.
If the username and password changed, after **TouchID** authentication, the app alerts the user to re-enter username and password again.  
  
####Map and Table Tabbed View  
This view has two tabs at the bottom: one specifying a map, and the other a table. When the map tab is selected, the view displays a map with pins specifying the last 100 locations posted by students. The user is able to zoom and scroll the map to any location using standard pinch and drag gestures. When the user taps a pin, it displays the pin annotation popup, with the student’s name (pulled from their Udacity profile) and the link associated with the student’s pin.  
Tapping anywhere within the annotation launches Safari and directs it to the link associated with the pin. Tapping outside of the annotation dismisses or hides it. When the table tab is selected, the most recent 100 locations posted by students are displayed in a table. Each row displays the name from the student’s Udacity profile. Tapping on the row launches Safari and opens the link associated with the student.  
Both the map tab and the table tab share the same top navigation bar. Clicking on the rightmost bar refresh button refreshes the entire data set by downloading and displaying the most recent 100 posts made by students. Clicking on the pin button which is at the left of the bar button,modally presents the **Information Posting View**.  
If authentication is done by Facebook, clicking on the "logout" bar button in the top left corner, allowes to user to logout.  
  
####Information Posting View  
The **Information Posting View** allows users to input data in two steps: first adding their location string, then their link.
When the **Information Posting View** is modally presented, the user sees a prompt asking where they are studying. The user enters a string into a text field or text view.  
When the user clicks on the “Find on the Map” button, the app forwards geocode the string. If the forward geocode fails, the app will display an alert view notifying the user.  
If the forward geocode succeeds then the prompt, text field, and button gets hidden, and a map showing the entered location is displayed. A new text field allows users to paste or type in the link that they would like to be associated with their location. A new button is displayed allowing the user to submit their data. If the link is empty, the app displays an alert view notifying the user.  
If the submission fails to post the data to the server, then the user sees an alert with an error message describing the failure.  
If at any point the user clicks on the “Cancel” button, then the **Information Posting View** is dismissed, returning the app to the **Map and Table Tabbed View**.  
 if the submission succeeds, then the **Information Posting View** is dismissed, returning the app to the **Map and Table Tabbed View**.





