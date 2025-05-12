//
//  AppVersionSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI

struct AppVersionSection: View {
    var body: some View {
        HStack {
            Text("버전")
            Spacer()
            Text("\(Constants.getAppVersion())")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    AppVersionSection()
}
