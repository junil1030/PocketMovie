//
//  EmailSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI
import MessageUI

struct EmailSection: View {
    @State private var showMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        Button {
            sendEmail()
        } label: {
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.blue)
                Text("문의하기")
            }
        }
        .sheet(isPresented: $showMailView) {
            MailView(result: $mailResult, mailSettings: getMailSettings())
        }
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            showMailView = true
        } else {
            print("메일 앱을 사용할 수 없습니다.")
        }
    }
    
    private func createEmailURL() -> URL? {
        let mailSettings = getMailSettings()
        let recipients = mailSettings.recipients.joined(separator: ",")
        let subject = mailSettings.subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = mailSettings.body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "mailto:\(recipients)?subject=\(subject)&body=\(body)"
        return URL(string: urlString)
    }
    
    private func getMailSettings() -> (recipients: [String], subject: String, body: String) {
        
        let bodyString = """
        문의 사항 및 의견을 작성해주세요.
        
        
        -------------------
        Device Model : \(Constants.getDevieceModelName())
        Device OS : \(Constants.getDeviceOS())
        App Version : \(Constants.getAppVersion())
        
        -------------------
        """
        
        return (["dccrdseo@naver.com"], "[PocketMovie] 문의", bodyString)
    }
}

// MARK: - 메일 뷰
struct MailView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?
    let mailSettings: (recipients: [String], subject: String, body: String)
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(mailSettings.recipients)
        composer.setSubject(mailSettings.subject)
        composer.setMessageBody(mailSettings.body, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            controller.dismiss(animated: true)
        }
    }
}

#Preview {
    EmailSection()
}
