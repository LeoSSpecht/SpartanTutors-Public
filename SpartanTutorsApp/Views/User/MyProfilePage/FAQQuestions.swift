//
//  FAQQuestions.swift
//  SpartanTutors
//
//  Created by Leo on 7/28/22.
//

import Foundation

class FAQQuestions: ObservableObject{
    @Published var questions = [
        1:Question(question: "How do I cancel a session that I've already paid for?", answer: "In order to cancel a tutoring session, simply text (616)-275-4262 the following message: Your Name + “CANCEL SESSION”. Example: “Johnny Appleseed CANCEL SESSION”. We will refund the money you paid for the session as soon as possible. Please note there is a small fee for cancelling sessions that have already been paid for as it fills up time on our schedule that other students are unable to book. Review our cancellation policy to learn more."),
        2:Question(question: "Where are the tutoring sessions held?", answer: "All tutoring sessions are held through Zoom."),
        3:Question(question: "How do I book a one hour session?", answer: "We primarily offer two hour sessions for students as we have found that when students book a session for just one hour they are often using the tutor to just finish their homework rather than actually learn. This is not beneficial to anybody and it ends up hurting students more than they think as they are not learning the content that will come up on exams. With this in mind if you decide that a one hour session will better for you for whatever reason, follow these steps to book one. First book a session with the starting time you want, send $35 through one of our various payment methods, text (616)-275-4262 the following message: Your Name + “1 HOUR”. After all these steps are complete we will approve your session and let our tutors know that the session will only be one hour long."),
        4:Question(question: "Do you offer group tutoring sessions?", answer: "Group tutoring sessions is class dependent. For any computer science, writing, or information technology class the answer is no as students often have to complete unique work when writing code or essays. However for any other class we can make it work. Simply text (616)-275-4262 the following message: Your Name + “GROUP SESSION” and we can get it handled from there. Discounts on sessions will be given to each individual student in the group session and it will be discussed through text."),
        5:Question(question: "Where are tutors from?", answer: "All tutors are students at MSU."),
        6:Question(question: "As a student, what can I expect from my tutoring session?", answer: "Students can expect a tutoring session that is not focused solely on finishing homework and projects, but instead on making sure students are learning the concepts needed to complete their homework and projects. We emphasize the learning process over anything else as we have found that this method of tutoring allows for students to perform far better on exams than if they are just using tutors to finish their homework."),
        7:Question(question: "How do I contact my tutor?", answer: "The goal of this application is to allow students to book tutoring sessions as quick as possible. It removes the hassle of going back and forth with tutors to figure out what time works for both of you. You will not be in contact with your tutor until the session starts. If there are any questions or concerns please text us at (616)-275-4262 and we will get back to you as soon as possible."),
        8:Question(question: "Are tutors qualified in their subjects?", answer: "Yes each tutor has gone through a strict interview process and trainings on methods that we have found to help students perform well on exams in their class."),
        9:Question(question: "Can I work with the same tutor again?", answer: "Yes! Just visit the “Book a Session” page and select the tutor you want to work with. From there you can select a time that the tutor you want to work with is available."),
        10:Question(question: "Can I book multiple sessions at once?", answer: "Yes! It is highly advised to book several sessions at once especially if you know that you will be needing help with several homework assignments, projects, and studying for exams over the next few weeks. The reason why is because if you know that a busy schedule is coming up for the class, it means other students do too and you want to make sure that you get a session when you need it before they fill up."),
        11:Question(question: "How often should I meet with a tutor?", answer: "It depends on how comfortable you are with the class and doing work on your own. Once you meet with a tutor, ask them how often they think you should meet with them and go from there. They will often have the best idea of how to proceed."),
        12:Question(question: "How much improvement can I expect from working with a tutor?", answer: "It all depends on you. You get in what you put out. As long as you are focused during tutoring sessions and using the time wisely to learn everything that you are struggling with, you will see great improvements from having tutoring sessions."),
    ]
}