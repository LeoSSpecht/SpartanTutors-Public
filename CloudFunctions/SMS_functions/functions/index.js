const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

const twilio = require('twilio');
require('dotenv').config();
// const accountSid = functions.config().twilio.twilio_account_sid;
// const authToken = functions.config().twilio.twilio_auth_token;
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const client = new twilio(accountSid, authToken);
const verified_destination = "+19087747852";

const payment_reminder_message_night = "Just a friendly reminder you have a session tomorrow morning pending payment";
const payment_reminder_message_midday = "Just a friendly reminder you have a session today pending payment";
const payment_reminder_2h = "Just a friendly reminder you have a session soon pending payment";

const session_reminder = "Just a friendly reminder you have a session in 1 hour with";

const heading = "Hello from Spartan Tutors!\n"

const morning_pending = "Just a friendly reminder, you have a session today at "
const night_pending = "Just a friendly reminder, you have a session tomorrow on "
const pending_end = ` that is pending payment. 

Once you send the money you will receive the Zoom link for the session and such. 
Text us at (616)-275-4262 if you are having any issues. Have a nice night!`

const pending_end_day = ` that is pending payment. 

Once you send the money you will receive the Zoom link for the session and such. 
Text us at (616)-275-4262 if you are having any issues. Have a nice day!`

const reminder_begin = "Just a friendly reminder, you have a session in 2 hours with" 
const reminder_end = `that is pending payment. 

Once you send the money you will receive the Zoom link for the session and such. 
Text us at (616)-275-4262 if you are having any issues or need to cancel the session.`

const review_begin = `\nWe hope you had a nice session with`;
const review_end = `\nPlease fill out this 1 minute form if you would like to review your session and help us improve our services!

Here's the link: https://bit.ly/3SjkPoF`

const hours_payment_reminder = 2;

const date_options = {
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
        date.toLocaleString("en-US",date_options) + " EST";

    return week_day_name + " " +month.padStart(2, '0') + "/" + day.padStart(2,"0") + " " + time;
}


function create_message(message_type, session_date,name, secondary_name = ""){
  switch(message_type){
    case "night_pending":
      var session_time = session_date.toDate();
      var session_data = `${format_date(session_time)} with ${name}`
      return heading + night_pending + session_data + pending_end;

    case "morning_pending":
      var session_time = session_date.toDate();
      var session_data = `${format_date(session_time)} with ${name}`
      return heading + morning_pending + session_data + pending_end_day;

    case "payment_reminder":
      var session_data = ` ${name} `;
      return heading + reminder_begin + session_data + reminder_end;

    case "reminder":
      return session_reminder + ` ${name} `;

    case "review":
      return `Hello ${secondary_name}!\n`+ review_begin + ` ${name}.` + review_end;
  }
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

function send_SMS(destination, message){
  var final_message = message
  client.messages
  .create({
       body: final_message,
       from: '+13605054773',
       to: destination
  })
  .then(message => console.log(message.sid));
}

function get_sessions(initial_time, final_time, status){
    //Gets all the sessions depending on initial and final time
    //Also filters by status
    // Returns Dict
    // {
    //  "tutor": {"tutor_id":[sessions]},
    //  "student": {"student_id":[sessions]}
    // }
    let query = db.collection("Sessions")
    .where('date', '>=', initial_time)
    .where('date', '<=', final_time)
    .orderBy("date");

    return new Promise(function (resolve, reject){
        query.get()
        .then(response => {
            if (response.empty) {
                reject("No documents found");
            }
            let docs = response.docs;
            
            let students_sessions = {};
            let tutor_sessions = {};
            
            for (session_i in docs){
                let session_data = docs[session_i].data();
                if(session_data.status == status){
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
            reject("Error requesting firebase");
        })
    });
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

function send_session_messages(sessions, phone_numbers,message, receiver = "student"){
  return new Promise(async function (resolve, reject){
    try{
      for (id in sessions){
        //Get student phone number
        if (id in phone_numbers){
          //Send message
          var sessions_for_user = sessions[id];
          let phone_number = phone_numbers[id];
          for(session_i in sessions_for_user){
            let session_data = sessions_for_user[session_i];
            let session_date = session_data.date
            var name = ""
            if (receiver == "student"){
              var user_data = await get_user_data(session_data.tutor_uid)
              name = user_data.name
            }
            else{
              var user_data = await get_user_data(session_data.student_uid)
              name = user_data.name
            }

            var formatted_message = "";
            if (message == "review"){
              var student_data = await get_user_data(session_data.student_uid)
              var student_first_name = student_data.name.split(" ")[0];
              formatted_message = create_message(message,session_date,name,student_first_name);
            }
            else{
              formatted_message = create_message(message,session_date,name);
            }
            
            send_SMS(phone_number,formatted_message);
          }
        }
      }
      resolve("Messages sent");
    }
    catch(err){
      reject(err)
    }
    
  }) 
}

function get_time_range(hours = 0, min = 0, date = new Date(), def_delta_hours = 0){
  var today = date;
  var delta_hours = 1000*60*60*hours;
  var delta_mins = 1000*60*min;
  var delta = delta_mins+delta_hours;
  var initial_time = new Date(today.getTime() - delta + def_delta_hours*60*60*1000);
  var final_time = new Date(today.getTime() + delta + def_delta_hours*60*60*1000);
  return [initial_time, final_time];
}

async function near_session_payment_reminder(){
  var time_range = get_time_range(0,5,undefined,2);
  var sessions = await get_sessions(time_range[0],time_range[1],"Pending");
  var phone_numbers = await get_all_user_phones();
  return new Promise(async function (resolve,reject){
    try{
      var messaged = await send_session_messages(sessions["student"], phone_numbers,"payment_reminder");
      resolve(messaged);
    }
    catch(err){
      reject(err)
    }
  })
}

async function near_session_reminder(){
  var time_range = get_time_range(0,5,undefined,1);

  var sessions = await get_sessions(time_range[0],time_range[1],"Approved");
  var phone_numbers = await get_all_user_phones();
  return new Promise(async function (resolve,reject){
    try{
      var messaged_student = await send_session_messages(sessions["student"], phone_numbers,"reminder");
      var messaged_tutor = await send_session_messages(sessions["tutor"], phone_numbers,"reminder", "tutor");
      resolve(messaged_tutor);
    }
    catch(err){
      reject(err)
    }
  })
}

async function past_session_review(){
  var time_range = get_time_range(0,5,undefined,-2);
  console.log(time_range);
  var sessions = await get_sessions(time_range[0],time_range[1],"Approved");
  var phone_numbers = await get_all_user_phones();
  return new Promise(async function (resolve,reject){
    try{
      var messaged_student = await send_session_messages(sessions["student"], phone_numbers,"review");
      resolve(messaged_student);
    }
    catch(err){
      reject(err)
    }
  })
}

exports.night_pending_payment = functions.pubsub.schedule('30 19 * * *')
    .timeZone('America/New_York')
    .onRun(async (context) => {
  // payment
  var original_time = new Date()
  var today = new Date().toLocaleString("en-US", { timeZone: 'America/New_York' });
  var today = new Date(today);

  var hourDiff = original_time.getHours() - today.getHours();
  if(hourDiff < 0){
    hourDiff = hourDiff + 24
  }

  today.setHours(0,0,0,0);
  
  var day = 60 * 60 * 24 * 1000;
  var half_day = 60 * 60 * 12 * 1000;
  var midnight_tomorrow = new Date(today.getTime() + day + hourDiff*60*60*1000);
  var midday_tomorrow = new Date(today.getTime() + day+ half_day+hourDiff*60*60*1000);

  try{
    var sessions = await get_sessions(midnight_tomorrow,midday_tomorrow,"Pending");
    var phone_numbers = await get_all_user_phones();
    var sent_messages = await send_session_messages(sessions["student"],phone_numbers, "night_pending");
    // response.status(200).send(sent_messages);
  }
  catch(err){
    console.log("Some error occured: " + err);
    // response.status(500).send("Error");
  }
});

exports.morning_pending_payment = functions.pubsub.schedule('0 11 * * *')
    .timeZone('America/New_York')
    .onRun(async (context) => {
    var original_time = new Date()
    var today = new Date().toLocaleString("en-US", { timeZone: 'America/New_York' });
    var today = new Date(today);

    var hourDiff = original_time.getHours() - today.getHours();
    if(hourDiff < 0){
      hourDiff = hourDiff + 24
    }

    today.setHours(0,0,0,0);

    var day = 60 * 60 * 24 * 1000;
    var half_day = 60 * 60 * 12 * 1000;
    var midday_today= new Date(today.getTime() + half_day+ hourDiff*60*60*1000);
    var midnight_today = new Date(today.getTime() + day+ hourDiff*60*60*1000);

    try{
      var sessions = await get_sessions(midday_today,midnight_today,"Pending");
      console.log(sessions);
      var phone_numbers = await get_all_user_phones();
      var sent_messages = await send_session_messages(sessions["student"],phone_numbers,"morning_pending");
      // response.status(200).send(sent_messages);
    }
    catch(err){
      console.log("Some error occured: " + err);
      // response.status(500).send("Error");
    }
});

exports.session_reminders = functions.pubsub.schedule('0-45/15 6-21/1 * * *')
    .timeZone('America/New_York')
    .onRun(async (context) => {
      var status = 400;
      var res = "";

      try{
        var sessions_pending = await near_session_payment_reminder()
        res = res + "Pending payment messages sent "
      }
      catch(err){
        console.log("Some error occured: " + err);
        status = 500
        res = res + err
      }

      try{
        var sessions_reminder = await near_session_reminder()
        res = res + "Session reminder messages sent "
      }
      catch(err){
        console.log("Some error occured: " + err);
        status = 500
        res = res + err
      }

      try{
        var sessions_reminder = await past_session_review()
        res = res + "Session review messages sent "
      }
      catch(err){
        console.log("Some error occured: " + err);
        status = 500
        res = res + err
      }

      // response.status(status).send(res);
    })










