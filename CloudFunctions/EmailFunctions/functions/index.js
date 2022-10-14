const functions = require('firebase-functions');
const admin = require('firebase-admin');
require('dotenv').config();
const nodemailer = require('nodemailer');
const cors = require('cors')({origin: true});

admin.initializeApp();
const db = admin.firestore();

const twilio = require('twilio');

// const accountSid = functions.config().twilio.twilio_account_sid;
// const authToken = functions.config().twilio.twilio_auth_token;
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;


const verified_destination = "+19087747852";

const date_options_hours = {
  hour: 'numeric',
  minute: 'numeric',
  timeZone: 'America/New_York'
};

function format_date(date){
  var week_days = ["Sun","Mon","Tue","Wed", "Thu", "Fri", "Sat"]
  var day = date.getDate().toString();
  var month = (date.getMonth()+1).toString();
  var week_day_num = date.getDay();
  var week_day_name = week_days[week_day_num];

  var time = 
        date.toLocaleString("en-US",date_options_hours) + " EST";

    return week_day_name + " " +month.padStart(2, '0') + "/" + day.padStart(2,"0") + " " + time;
}


function send_SMS(destination, message){
    const client = new twilio(accountSid, authToken);
    var final_message = message
    client.messages
    .create({
       body: final_message,
       from: '+13605054773',
       to: destination
    })
    .catch(err => console.log(err))
}

function get_all_user_phones(){
    let query = db.collection("users")
    return new Promise(function (resolve, reject){
        query.get()
        .then( async function(response) {
            if (response.empty) {
                reject("No documents found");
            }

            let docs = response.docs;
            let all_user_data = {};

            for (user_obj in docs){
              let id = docs[user_obj].id;
              let user_data = docs[user_obj].data();

              var phone = "";
              if("phone" in user_data){
                phone = user_data.phone
              }
              all_user_data[id] = phone;
            }
            resolve(all_user_data);
        })
        .catch((error) => {
            reject("Firebase error");
        })
    });
}

function get_one_user_phones(uid){
    let query = db.collection("users").doc(uid);

    return new Promise(function (resolve, reject){
        query.get()
        .then(async (doc) => {
            if (doc.exists) {
                var doc_data = doc.data();
                var phone = "";
                  if("phone" in doc_data){
                    phone = doc_data.phone
                  }
                  resolve(phone);
            } else {
                reject("No user found");
            }
        })
        .catch((error) => {
            reject("Firebase error");
        })
    });
}

const transporter = nodemailer.createTransport({
    host: 'smtp.sendgrid.net',
    port: 465,
    auth: {
        user: 'apikey',
        pass: process.env.SEND_GRID_API_KEY
    }
});

const html_header = `<!DOCTYPE html>
                        <html>
                            <head>
                                <meta name="viewport" content="width=device-width, initial-scale=1">
                                <style>
                                    body {background-color:#ffffff;background-repeat:no-repeat;background-position:top left;background-attachment:fixed;}
                                    h1{text-align:center;font-family:Helvetica, sans-serif;color:#ffffff;background-color:#18543b;padding: 30px}
                                    p {font-family:Helvetica, sans-serif;font-size:14px;font-style:normal;font-weight:normal;color:#000000;background-color:#ffffff;}
                                    b {font-family:Helvetica, sans-serif;font-size:14px;font-style:normal;color:#000000;background-color:#ffffff;}
                                    span {font-family:Helvetica, sans-serif;font-size:14px;font-style:normal;color:#000000;background-color:#ffffff;}
                                </style>
                            </head>
                            <body>
                                <h1>Spartan Tutors</h1>`;

const date_options = {
  year: 'numeric',
  month: 'numeric',
  day: 'numeric',
  hour: 'numeric',
  minute: 'numeric',
  timeZone: 'America/New_York'
};

function send_approved_email(destination, subject, text,html){
    const mailOptions = {
        from: 'Spartan Tutors <info@spartantutorsmsu.com>', // Something like: Jane Doe <janedoe@gmail.com>
        to: destination,
        subject: subject,
        text: text,
        html: html
    };

    // returning result
    return transporter.sendMail(mailOptions, (erro, info) => {
        if(erro){
            console.log(erro);
            return false;
        }
        console.log("email sent");
        return true;
    });
}

// Approved email
function student_session_approved_email(user_data,session_data, tutor_data){
    let name = user_data.displayName;

    return html_header+
        `<p>Hi <b>${name}</b>,</p>
        <p>We just received your payment and confirmed the following session.</p>
        ${fill_student_session_html(session_data,tutor_data)}
        <p>Thanks and have an amazing day!</p>
        </body>
    </html>`;
}

function tutor_session_approved_email(session_data, tutor_name, student_name){
    return html_header+
        `<p>Hi <b>${tutor_name}</b>,</p>
        <p>You just got a new session confirmed, please go to the app for more information.</p>
        ${fill_tutor_session_html(session_data,student_name)}
        <p>Thanks and have an amazing day!</p>
        </body>
    </html>`;
}

function fill_tutor_session_html(session_data, student_name){
    let session_time = 
        session_data
            .date
            .toDate()
            .toLocaleString("en-US",date_options) + " EST";

    let session_class = session_data.college_class;
    return `<b>
    Session time: ${session_time}
    <br>
    Class: ${session_class}
    <br>
    Student: ${student_name}
    </b>`;
}

function fill_student_session_html(session_data, tutor_data){
    let session_time = 
        session_data
            .date
            .toDate()
            .toLocaleString("en-US",date_options) + " EST";

    let session_class = session_data.college_class
    let tutor_name = tutor_data[session_data.tutor_uid].name;
    let zoom_link = tutor_data[session_data.tutor_uid].zoom_link;
    let zoom_password = tutor_data[session_data.tutor_uid].zoom_password;
    return `<b>
    Session time: ${session_time}
    <br>
    Class: ${session_class}
    <br>
    Tutor: ${tutor_name}
    <br>
    Zoom link: ${zoom_link}
    <br>
    Zoom password: ${zoom_password}
    </b>`
}

function get_all_tutors(){
    let query = db.collection("users").where('role', '==', 'tutor');
    return new Promise(function (resolve, reject){
        query.get()
        .then( async function(response) {
            if (response.empty) {
                console.log('No documents found.');
                resolve(false);
            }
            let docs = response.docs;
            let all_tutors_data = {};
            for (tutor_obj in docs){
                let tutor_id = docs[tutor_obj].id;
                let tutor_data = docs[tutor_obj].data();
                var zoom_password = "";
                let tutor_email = await get_user_data(tutor_id);
                if("zoom_password" in tutor_data){
                    zoom_password = tutor_data.zoom_password;
                }
                all_tutors_data[tutor_id] = {
                    "name": tutor_data.name,
                    "zoom_link": tutor_data.zoom_link, 
                    "zoom_password": zoom_password,
                    "email": tutor_email.email
                }
            }
            resolve(all_tutors_data);

        })
        .catch((error) => {
            resolve(null);
        })
    });
}

//Returns Id->Name
function get_all_students_names(){
    let query = db.collection("users").where('role', '==', 'student');
    return new Promise(function (resolve, reject){
        query.get()
        .then(function(response) {
            if (response.empty) {
                console.log('No documents found.');
                resolve(false);
            }
            let docs = response.docs;
            let all_students = {};
            for (student_index in docs){
                let student_id = docs[student_index].id;
                let student_data = docs[student_index].data();
                all_students[student_id] = student_data.name
            }
            resolve(all_students);

        })
        .catch((error) => {
            resolve(null);
        })
    });
}

function get_user_data(user_id){
    return new Promise(function (resolve,reject){
        admin.auth()
            .getUser(user_id)
            .then((userRecord) => {
                let email = userRecord.email;
                let name = userRecord.displayName;
                resolve({"email": email, "name": name});
            })
            .catch((error) => {
                functions.logger.log('Error fetching user data:', error);
                reject(error);
            });
    }) 
}

function get_all_sessions_for_day(today, tomorrow){
    let query = db.collection("Sessions")
    .where('date', '>=', today)
    .where('date', '<=', tomorrow)
    .orderBy("date");
    return new Promise(function (resolve, reject){
        query.get()
        .then(response => {
            if (response.empty) {
                console.log('No documents found.');
                reject(false);
            }
            let docs = response.docs;
            let students_sessions = {};
            let tutor_sessions = {};
            
            for (session_i in docs){
                let session_data = docs[session_i].data();
                if(session_data.status == "Approved"){
                    
                    if(!(session_data.student_uid in students_sessions)){
                        students_sessions[session_data.student_uid] = []
                    }
                    if(!(session_data.tutor_uid in tutor_sessions)){
                        tutor_sessions[session_data.tutor_uid] = []
                    }
                    tutor_sessions[session_data.tutor_uid].push(session_data);
                    students_sessions[session_data.student_uid].push(session_data);
                }
                
            }
            resolve({"student":students_sessions, "tutor": tutor_sessions});

        })
        .catch((error) => {
            console.log(error)
            reject(null);
        })
    });
}

function student_daily_sessions_email(student_data,sessions_list,tutor_data){
    var sessions_html = ""
    let name = student_data.displayName;
    let n_of_sessions = sessions_list.length;
    for(session_i in sessions_list){
        let session_data = sessions_list[session_i];
        let session_html = fill_student_session_html(session_data, tutor_data) +`<br><br>`
        sessions_html += session_html;
    }
    let html = html_header + `
                            <p>Hi <b>${name}</b>,</p>
                            <p>Just a quick reminder, you have ${n_of_sessions} session(s) today.
                            <br>They are:</p>
                            ${sessions_html}
                            <span>Thanks and have an amazing day!<br>Spartan Tutors</span>
                        </body>
                    </html>`;
    return html;
}

function tutor_daily_sessions_email(tutor_id, student_names, sessions_list,tutor_data){
    var sessions_html = ""
    let name = tutor_data[tutor_id].name;
    let n_of_sessions = sessions_list.length;
    for(session_i in sessions_list){
        let session_data = sessions_list[session_i];
        let student_name = student_names[session_data.student_uid];
        let session_html = fill_tutor_session_html(session_data, student_name) +`<br><br>`
        sessions_html += session_html;
    }
    let html = html_header + `
                            <p>Hi <b>${name}</b>,</p>
                            <p>Just a quick reminder, you have ${n_of_sessions} session(s) today.
                            <br>They are:</p>
                            ${sessions_html}
                            <span>Thanks and have an amazing day!<br>Spartan Tutors</span>
                        </body>
                    </html>`;
    return html;
}

function prepare_daily_student_email(student_id, student_sessions,tutor_data){
    return new Promise(function (resolve, reject){
        admin.auth()
            .getUser(student_id)
            .then((userRecord) => {
                let email = userRecord.email;
                let html = student_daily_sessions_email(userRecord, student_sessions, tutor_data);
                let sent_email = send_approved_email(email, "Session reminder", "",html);
                resolve(true);
            })
            .catch((error) => {
                functions.logger.log('Error fetching user data:', error);
                reject(error);
            });
        });
}

function prepare_daily_tutor_email(tutor_id,student_names,tutor_sessions,tutor_data){
    return new Promise( function (resolve, reject){
            let email = tutor_data[tutor_id].email
            let html = tutor_daily_sessions_email(tutor_id, student_names,tutor_sessions, tutor_data);
            let tutor_html = send_approved_email(email, "Session reminder", "",html);
            resolve(true);
        });
}

exports.updated_session = functions.firestore
	.document('Sessions/{sessionID}')
	.onUpdate(async (change, context) => {
		const newValue = change.after.data();
    	const previousValue = change.before.data();

        // Compares the values from old state to new state 
    	if(newValue.status == "Approved" && previousValue.status == "Pending"){
            // Session was approved
            let tutor_data = await get_all_tutors();
    		let user_id = newValue.student_uid;
            // Getting user email
    		admin.auth()
	    		.getUser(user_id)
	    		.then(async (userRecord) => {
                    // Gets user information
                    let email = userRecord.email;
                    let student_name = userRecord.displayName;
                    let html = student_session_approved_email(userRecord, newValue, tutor_data);
                    let tutor_email_name = await get_user_data(newValue.tutor_uid);
                    let tutor_html = tutor_session_approved_email(newValue, tutor_email_name.name, student_name);

                    let tutor_phone_number = await get_one_user_phones(newValue.tutor_uid);
                    let student_phone_number = await get_one_user_phones(user_id);

                    send_approved_email(email, "Session confirmation", "",html);
                    send_approved_email(tutor_email_name.email, "New session confirmed", "",tutor_html);

                    let hours = newValue
                        .date
                        .toDate()
                        .toLocaleString("en-US",date_options_hours) + " EST";

                    //Send message to student
                    send_SMS(student_phone_number, `Hi from Spartan Tutors!\nYour session with ${tutor_email_name.name} at ${hours} was confirmed.`);
                    //Send message to tutor
                    send_SMS(tutor_phone_number, `Hi from Spartan Tutors!\nYour session with ${student_name} at ${hours} was confirmed.`);
				})
				.catch((error) => {
				    functions.logger.log('Error fetching user data:', error);
				});
		};

	});

exports.created_session = functions.firestore
    .document('Sessions/{sessionID}')
    .onCreate(async (snap, context) => {
      // Get an object representing the document
      // e.g. {'name': 'Marie', 'age': 66}
      const newSessionData = snap.data();

      let session_time = format_date(newSessionData.date.toDate());
      let tutor_id = newSessionData.tutor_uid;

      let tutor_phone_number = await get_one_user_phones(tutor_id);
      let student_data = await get_user_data(newSessionData.student_uid);
      let student_name = student_data.name;

      let message = 'Hello from Spartan Tutors!\n' + `You have a new session pending with ${student_name} on ${session_time}.`;
      send_SMS(tutor_phone_number, message);
  });

exports.new_user = functions.firestore
    .document('users/{user_id}')
    .onCreate(async (snap, context) => {
        const newUserData = snap.data();
        let message = `A new student just logged in for the first time.`;
        send_SMS("2693124915", message);      
  });

exports.user_filled_forms = functions.firestore
    .document('users/{user_id}')
    .onUpdate(async (change, context) => {
        const newValue = change.after.data();
        const previousValue = change.before.data();
        
        if (previousValue.name == "" && newValue.name != ""){
            let message = `${newValue.name} | ${newValue.yearStatus} just filled sign in forms.`;
            send_SMS("2693124915", message);      
        }
        
  });

exports.daily_sessions_email = functions.pubsub.schedule('0 7 * * *')
    .timeZone('America/New_York')
    .onRun(async (context) => {
    var today = new Date().toLocaleString("en-US", { timeZone: 'America/New_York' });
    var today = new Date(today);
    today.setHours(0,0,0,0);
    var day = 60 * 60 * 24 * 1000;
    var tomorrow = new Date(today.getTime() + day);
    try{
        const all_sessions = await get_all_sessions_for_day(today,tomorrow);
        const student_sessions = all_sessions.student;
        const tutor_sessions = all_sessions.tutor;
        const tutor_data = await get_all_tutors();
        const student_names = await get_all_students_names();

        for(student_id in student_sessions){
            prepare_daily_student_email(student_id,student_sessions[student_id],tutor_data);
        }
        for(tutor_id in tutor_sessions){
            prepare_daily_tutor_email(tutor_id,student_names, tutor_sessions[tutor_id], tutor_data);
        }
        return true
    }
    catch(e){
        console.log(e)
    }
});












