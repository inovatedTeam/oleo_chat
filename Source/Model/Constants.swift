//
//  Constants.swift
//  ready
//
//  Created by Patrick Sheehan on 1/25/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import Foundation

public struct Constants {
    struct QuickBlox {
        // Andrei's
//        static let AppID: UInt = 42052
//        static let AuthKey = "XVusxwnyvN66kx2"
//        static let AuthSecret = "ukT6u5P2BK-KWey"
//        static let AccountKey = "ezxqXt8jGqjJSyYqx3Rt"
        
        // Patrick's
//        static let AppID: UInt = 42444
//        static let AuthKey = "5Wq7PtRpAx42p2c"
//        static let AuthSecret = "7sgeraVRwTbaa9T"
//        static let AccountKey = "m8mNAhcrVCQE5bLRnWpo"
        
        // oleo-test
        static let AppID: UInt = 45450
        static let AuthKey = "ugKBrXfTrsfcDY3"
        static let AuthSecret = "mq2-UJbU9Uwbp8K"
        static let AccountKey = "m8mNAhcrVCQE5bLRnWpo"
    }
    
    struct GoogleApi {

        struct Translate {
            static let BaseUrl = "https://www.googleapis.com/language/translate/v2"
            static let APIKey = "AIzaSyD-WarO0YCSI384W75fnzUeHhh33CGIeqk"
            static let BrowserAPIKey = "AIzaSyCRC2eUnlKqmEQRLs-kIpynI0fhUY9nk_o"
        }
    }
    
    struct Colors {
        static let Gold = UIColor(netHex: 0xFFCC33)
        static let Lavender = UIColor(netHex: 0x8400FF)
        static let Aqua = UIColor(netHex: 0xE8C52F)
    }
    
    struct DeviceInfo {
        static let DefaultDeviceToken = "2222222"
        static let DeviceType = "ios"
    }
    
    struct MessageType {
        static let Text = "text"
        static let Audio = "audio"
        static let Video = "video"
    }
    
    struct APINames {
        static let SignUp = "account/signup"
        static let Login = "account/login"
        static let Logout = "account/logout"
        static let UpdateProfile = "account/updateProfile"
        
        static let GetMissingMessages = "chat/getLatestMessages"
        static let SendMessage = "chat/sendMessage"
        static let GetChatHistory = "chat/getChatHistory"
        static let GetChatHistoryOfStudents = "chat/getChatHistoryOfStudents"
        static let CheckMessage = "chat/checkMessage"
        static let GetTeachers = "member/get_teacher"
        static let GetStudents = "member/get_student"
        static let GetStudentInfo = "member/get_student_info"
        
        static let CreateClassroom = "classroom/createClassroom"
        static let DestroyClassroom = "classroom/destroyClassroom"
        static let JoinStudentsClassroom = "classroom/joinStudentsIntoClassroom"
        static let EnrollClassroom = "classroom/enrollClassroom"
        static let LeaveClassroom = "classroom/leaveClassroom"
        static let GetClassroomsForTeachers = "classroom/getClassroomsForTeachers"
        static let GetAvailableClassrooms = "classroom/getAvailableClassrooms"
        static let GetEnrolledClassrooms = "classroom/getEnrolledClassrooms"
        static let GetStudentsInClassroom = "classroom/getStudentsInClassroom"
        static let GetStudentsInTeacher = "classroom/getStudentsInTeacher"
        static let EnrollClassroomWithPin = "classroom/classRegistration"
        
        static let StartAssignment = "assignment/startAssignment"
        static let EndAssignment = "assignment/endAssignment"
        static let GetAllAssignments = "assignment/getAllAssignments"
        static let CompleteAssignment = "assignment/completeAssignment"
        
        static let VideoCallUpload = "audio/upload"
    }

    struct WebServiceApi {
//        static let DocumentRoot = "http://37.59.210.116/oleo-backend"
        static let DocumentRoot = "https://oleo.tech/oleo-backend"
  
        static let ApiBaseUrl = "\(DocumentRoot)/api/"
        static let imageBaseUrl = "\(DocumentRoot)/images/avatar/"
        static let audioBaseUrl = "\(DocumentRoot)/images/audio/"
        static let videoBaseUrl = "\(DocumentRoot)/images/video/"
        
//        static let ApiBaseUrl = "http://37.59.210.116/speaq-web-app/api/"
//        static let imageBaseUrl = "http://37.59.210.116/speaq-web-app/images/avatar/"
//        static let audioBaseUrl = "http://37.59.210.116/speaq-web-app/images/audio/"
//        static let videoBaseUrl = "http://37.59.210.116/speaq-web-app/images/video/"
    }
    
    struct TwitterApi {
        static let BaseUrl = "https://api.twitter.com/1.1/"
    }
    
    struct Configuration {
        static let UseWorkaround = true
    }
    
}