//
//  EmailRegisterView.swift
//  Bottles_V2
//
//  Created by BOMBSGIE on 2023/01/30.
//

import SwiftUI

struct EmailRegisterView: View {
    
    @StateObject var authStore: AuthStore
    
    @EnvironmentObject var userStore: UserStore
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    /// email확인 정규식
    let emailExpression: String = "^([a-zA-Z0-9._-])+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{3,20}$"
    
    /// 비밀번호 확인 정규식 (영어, 숫자, 특수문자 8~18자리)
    let passwordExpression: String = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,15}$"
    
    
    @State var registerEmail: String = ""
    @State var verificationCode: String = ""
    @State var registerPassword: String = ""
    @State var passwordCheck: String = ""
    @State var nickname: String = ""
    @State var phoneNumber: String = ""
    
    // 휴대폰 번호와 닉네임의 최대 글자수
    let phoneNumberMaximumCount: Int = 11
    let nicknameMaximumCount: Int = 10
    
    /// 비밀번호 입력 창을 TextField로 보여주거나 SecureField로 보여주는 변수
    @State private var isShowingPasswordText: Bool = false
    
    /// 비밀번호 확인 입력창을 TextField로 보여주거나 SecureField로 보여주는 변수
    @State private var isShowingPasswordCheckText: Bool = false
    
    /// 중복확인 버튼을 누르고 이메일이 중복일 때 텍스트 필드 애니메이션을 활성화 시켜주는 변수
    @State private var emailError: Bool = false
    
    /// 비밀번호 양식이 올바르지 않으면 사용자에게 뷰에서 에러를 표현해주는 변수
    @State private var passwordError: Bool = false
    
    /// 비밀번호 확인이 같지 않으면 사용자에게 뷰에서 에러를 표현해주는 변수
    @State private var checkingPasswordError: Bool = false
    
    
    /// 전체 이용약관 동의 변수
    @State private var allAgreement: Bool = false
    /// 첫번째 이용약관 동의 변수
    @State private var firstAgreement: Bool = false
    
    /// 개인정보 수집 이용 동의 변수
    @State private var secondAgreement: Bool = false
    
    /// 만 19세 이상 동의 변수
    @State private var thirdAgreement: Bool = false
    
    /// 이용약관 버튼 눌렀을 때 이동하는 웹링크 배열
    let agreementURLs: [String] = [
        "https://buttercup-blue-7c3.notion.site/Bottles-2e87d483ef024a13941c31d6ddeccd1f", // 이용약관 동의 링크
        "https://buttercup-blue-7c3.notion.site/Bottles-7a8ac8ff1a5141ddb73f7eb808689f48", // 개인정보 수집·이용 동의 링크
    ]
    
    /// 이용약관 동의 필드의 텍스트 배열
    let agreementTitles: [String] = [
        "이용약관 동의",
        "개인정보 수집·이용 동의",
    ]
    
    /// SafariWebView에 바인딩으로 넘겨줄 웹 링크 각 버튼마다 눌렀을 때 링크가 변경된다.
    @State var selectedAgreementWebLink: URL = URL(string: "www.naver.com")!
    
    /// SafariWebView 시트로 띄우는 변수
    @State private var isShowingSheet: Bool = false
    
    /// 메일로 이메일 인증을 보냈을 때
    @State private var emailSent: Bool = false
    
    /// 중복확인을 눌렀을 때 CustomAlert을 띄워주는 변수
    @State private var dupilicateCheck: Bool = false
    
    /// 회원 가입 실패했을 때 CustomAlert을 띄워주는 변수
    @State private var registerFailed: Bool = false
    
    /// 회원 가입 성공했을 때 CustomAlert을 띄워주는 변수
    @State private var registerSuccessed: Bool = false
    
    
    var body: some View {
        ScrollView {
            // MARK: - email 입력창
            Group {
                HStack(alignment:.bottom){
                    Text("이메일")
                        .font(.bottles14)
                    + Text("*")
                        .foregroundColor(.accentColor)
                    Spacer()
                    // 뷰에 이메일 형식이 맞는지 틀린지 사용자가 볼 수 있게 Text로 띄워준다.
                    Text("\(resultEmailText)")
                        .font(.bottles12)
                        .foregroundColor(emailNotFitFormat ? .red : .green)
                }
                .padding(.horizontal, 20)
            
                HStack {
                    TextField("예: bottles@bottles.com", text: $registerEmail)
                        .keyboardType(.emailAddress)
                        .modifier(LoginTextFieldModifier(width: 250, height: 48))
                        
                    Button(action: {
                        // CustomAlert을 띄워 줌 이메일 중복에 따라 CustomAlert의 텍스트가 다르게 띄워짐
                        dupilicateCheck = true
                        // 중복확인 로직
                        userStore.doubleCheckEmail(userEmail: registerEmail)
                    }){
                       Text("중복확인")
                            .modifier(EmailViewButtonModifier(width: 100, height: 48))
                    }
                    .disabled(emailNotFitFormat) // 이메일 형식이 안맞을 때 버튼 비활성화
                
                }
            }
            
            
            // MARK: - 비밀번호 입력창
            Group {
                HStack(alignment: .bottom){
                    Text("비밀번호")
                        .font(.bottles14)
                    + Text("*")
                        .foregroundColor(.accentColor)
                    Spacer()
                    // 뷰에 비밀번호 형식이 맞는지 틀린지 사용자가 볼 수 있게 Text로 띄워준다.
                    Text("\(resultPasswordText)")
                        .font(.bottles12)
                        .foregroundColor(passwordNotFitFormat ? .secondary : .green)
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
                
                ZStack {
                    if isShowingPasswordText {
                        TextField("영어, 숫자, 특수문자 포함 8~15자리", text: $registerPassword)
//                            .padding(.top, 10)
                            .modifier(LoginTextFieldModifier(width: 357, height: 48))
                    } else {
                        SecureField("영어, 숫자, 특수문자 포함 8~15자리", text: $registerPassword)
                            .modifier(LoginTextFieldModifier(width: 357, height: 48))
                            .textContentType(.oneTimeCode)
                    }
                    HStack{
                        Spacer()
                        Button(action:{
                            isShowingPasswordText.toggle()
                        }){
                            Image(systemName: isShowingPasswordText ? "eye.slash" : "eye")
                        }
                    }
                    .padding(.trailing, 30)
                }
            }
            // MARK: - 비밀번호 확인
            Group {
                HStack {
                    Text("비밀번호 확인")
                        .font(.bottles14)
                    + Text("*")
                        .foregroundColor(.accentColor)
                    Spacer()
                    Text("\(resultPasswordCheckText)")
                        .font(.bottles12)
                        .foregroundColor(passwordCheckFail ? .red : .green)
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)

                ZStack{
                    // 버튼을 누름에 따라 TextField or SecureField
                    if isShowingPasswordCheckText {
                        TextField("비밀번호 확인", text: $passwordCheck)
                            .modifier(LoginTextFieldModifier(width: 357, height: 48))
                    } else {
                        SecureField("비밀번호 확인", text: $passwordCheck)
                            .modifier(LoginTextFieldModifier(width: 357, height: 48))
                            .textContentType(.oneTimeCode)
                    }
                    HStack{
                        Spacer()
                        Button(action:{
                            isShowingPasswordCheckText.toggle()
                        }){
                            Image(systemName: isShowingPasswordCheckText ? "eye.slash" : "eye")
                        }
                    }
                    .padding(.trailing, 30)
                }
            }
            
            // MARK: - 닉네임 입력
            Group {
                HStack {
                    Text("닉네임")
                        .font(.bottles14)
                    + Text("*")
                        .foregroundColor(.accentColor)
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
                .padding(.top, isShowingPasswordCheckText ? 4.5 : 5)
                
                TextField("닉네임을 입력해주세요.(최대 10자)", text: $nickname)
                    .modifier(LoginTextFieldModifier(width: 357, height: 48))
                    .onChange(of: nickname) { newValue in
                        if newValue.count > nicknameMaximumCount {
                            nickname = String(newValue.prefix(nicknameMaximumCount))
                        }
                    }
            }
            
            // MARK: - 휴대폰
            Group {
                HStack {
                    Text("휴대폰")
                        .font(.bottles14)
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
                
                TextField("숫자만 입력해주세요", text: $phoneNumber)
                    .modifier(LoginTextFieldModifier(width: 357, height: 48))
                    .keyboardType(.numberPad)
                    .onChange(of: phoneNumber) { newValue in
                        if newValue.count > phoneNumberMaximumCount {
                            phoneNumber = String(newValue.prefix(phoneNumberMaximumCount))
                        }
                    }
            }
            
            // MARK: - 이용약관동의
            Group {
                HStack {
                    Text("이용약관동의")
                        .font(.bottles14)
                    + Text("*")
                        .foregroundColor(.accentColor)
                    Spacer()
                }
                .padding(20)
                // MARK: - 이용약관 전체동의
                Button(action: {
                    if allAgreement {
                        firstAgreement = false
                        secondAgreement = false
                        thirdAgreement = false
                        allAgreement = false
                    } else {
                        firstAgreement = true
                        secondAgreement = true
                        thirdAgreement = true
                        allAgreement = true
                    }
                }){
                    HStack{
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundColor(firstAgreement && secondAgreement && thirdAgreement ? .accentColor : .secondary)
                        Text("전체 동의합니다.")
                            .font(.bottles19)
                            .foregroundColor(.primary)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                }
                Divider()
                    .padding(.horizontal, 16)
                // MARK: - 이용약관 동의 체크 버튼
                HStack {
                    VStack(spacing: 10) {
                        Button(action: {
                            firstAgreement.toggle()
                            allAgreement.toggle()
                        }) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(firstAgreement ? .accentColor : .secondary)
                                .font(.title2)
                        }
                        Button(action: {
                            secondAgreement.toggle()
                            allAgreement.toggle()
                        }) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(secondAgreement ? .accentColor : .secondary)
                                .font(.title2)
                        }
                        Button(action: {
                            thirdAgreement.toggle()
                            allAgreement.toggle()
                        }) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(thirdAgreement ? .accentColor : .secondary)
                                .font(.title2)
                        }
                    }
                    //MARK: - 이용약관 텍스트 눌렀을 때 웹으로 이동
                    VStack (alignment: .leading, spacing: 20){
                        ForEach(0 ..< agreementURLs.count, id: \.self){ index in
                            Button(action: {
                                selectedAgreementWebLink = URL(string: "\(agreementURLs[index])")!
                                isShowingSheet.toggle()
                            }){
                                HStack{
                                    Text("\(agreementTitles[index]) ")
                                        .foregroundColor(.primary)
                                    + Text("(필수)")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Image(systemName: "chevron.forward")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .font(.bottles12)
                            .sheet(isPresented: $isShowingSheet) {
                                SafariWebView(selectedUrl: $selectedAgreementWebLink)
                            }
                        }
                        Text("만 19세 이상입니다. ")
                            .font(.bottles12)
                        + Text("(필수)")
                            .font(.bottles12)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            
            // MARK: - 회원가입 버튼
            Button(action: {
                // TODO: 이메일로 회원가입 로직 넣기
                
                if emailNotFitFormat || passwordNotFitFormat || passwordCheckFail || nickname == "" || !firstAgreement || !secondAgreement || !thirdAgreement {
                    registerFailed = true
                } else {
                    authStore.registerUser(email: registerEmail, password: registerPassword, nickname: nickname, userPhoneNumber: phoneNumber)
                    registerSuccessed = true
                }
                 
//                authStore.registerUser(email: registerEmail, password: registerPassword, nickname: nickname, userPhoneNumber: phoneNumber)
//                registerSuccessed = true
            }){
                Text("회원가입하기")
                    .modifier(EmailViewButtonModifier(width: 358, height: 56))
            }
            
        }
        .onTapGesture{
            endTextEditing()
        }
        .customAlert(isPresented: $dupilicateCheck, message: userStore.emailCheckStr, primaryButtonTitle: "확인", primaryAction: {}, withCancelButton: false) // 이메일 중복확인 customAlert
        .customAlert(isPresented: $registerFailed, message: "입력하신 정보를 다시 확인해주세요.", primaryButtonTitle: "확인", primaryAction: {}, withCancelButton: false) // 회원가입 조건에 맞지 않을 때 띄워주는 customAlert
        .customAlert(isPresented: $registerSuccessed, message: "가입한 이메일의 인증 메일을 확인하면 회원 가입이 완료 됩니다", primaryButtonTitle: "확인", primaryAction: {self.presentationMode.wrappedValue.dismiss()}, withCancelButton: false) // 회원가입이 완료 되었을 때 띄워주는 customAlert
        .navigationBarTitle("회원가입")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    //MARK: - 뷰에 사용되는 연산프로퍼티들
    
    /// 이메일이 정규식에 맞는지 확인 해주는 연산프로퍼티
    private var emailNotFitFormat: Bool {
        registerEmail.range(of: emailExpression, options: .regularExpression) == nil
    }
    
    /// 비밀번호가 정규식에 맞는지 확인해주는 연산프로퍼티
    private var passwordNotFitFormat: Bool {
        registerPassword.range(of: passwordExpression, options: .regularExpression) == nil
    }
    
    /// 비밀번호와 비밀번호 확인이 서로 다르면 true 서로 같으면 false
    private var passwordCheckFail: Bool {
        passwordCheck != registerPassword
    }
    
    /// 뷰에 이메일 형식이 맞는지 텍스트로 띄워주는 연산 프로퍼티
    private var resultEmailText: String {
        if registerEmail == "" {
            return ""
        } else {
            return emailNotFitFormat ? "올바른 이메일 형식이 아닙니다." : "올바른 이메일 형식입니다."
        }
    }
    
    /// 뷰에 비밀번호 형식이 맞는지 텍스트로 띄워주는 연산 프로퍼티
    private var resultPasswordText: String {
        if registerPassword == "" {
            return ""
        } else {
            return passwordNotFitFormat ? "영어, 숫자, 특수문자 포함 8~15자리" : "사용 가능한 비밀번호 입니다."
        }
    }
    
    /// 뷰에 비밀번호 확인이 비밀번호 입력한 값과 맞는지 텍스트로 띄워주는 연산프로퍼티
    private var resultPasswordCheckText: String {
        if passwordCheck == "" {
            return ""
        } else {
            return passwordCheckFail ? "비밀번호가 일치하지 않습니다." : "비밀번호가 일치합니다."
        }
    }
    
    /// CustomNavigationBackButton
    var backButton : some View {
        Button(
            action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.backward")    // back button 이미지
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.black)
            }
    }
}


// MARK: - 쉐이크 이펙트

struct ShakeEffect: ViewModifier {
    
    var trigger: Bool
    
    @State private var isShaking = false
    
    func body(content: Content) -> some View {
        content // 수정자가 적용되는 곳 '위' 까지의 View
            .offset(x: isShaking ? -6 : .zero)
            .animation(.default.repeatCount(3).speed(6), value: isShaking)
            .onChange(of: trigger) { newValue in
                guard newValue else { return }
                isShaking = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isShaking = false
                }
            }
    }
}



struct EmailRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        EmailRegisterView(authStore: AuthStore()).environmentObject(UserStore())
    }
}
