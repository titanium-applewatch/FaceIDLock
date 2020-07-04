import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    @State var Developer = false
    
    var body: some View {
        NavigationView {
            Form {
                Section() {
                SheetView(btnTitle: "パスワード再設定", showTrigger: false)
                SheetView(btnTitle: "画面ロック", showTrigger: true)
                if UserDefaults.standard.bool(forKey: "cantfaceid") {
                    Text("生体認証の利用を許可してください")
                }
                }
            }.navigationTitle("リング")
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .onAppear() {
                impactMed.impactOccurred()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SheetView: View {
    @State var btnTitle:String
    @State var showTrigger = true
    
    var body: some View {
        VStack {
            Button(self.btnTitle) {
                self.showTrigger = true
                if self.btnTitle == "パスワード再設定" {
                    UserDefaults.standard.set("", forKey: "pass")
                    UserDefaults.standard.set("新しいパスワードを入力してください", forKey: "message")
                }
            }
        }.sheet(isPresented: $showTrigger, onDismiss: {
            print("sheet action")
        }) {
            LockView()
        }
    }
}

struct LockView: View {
    let generator = UINotificationFeedbackGenerator()
    @State var tapCount = UserDefaults.standard.string(forKey: "Taps") ?? "no"
    @State private var password: String = ""
    @State private var titleMessage = UserDefaults.standard.string(forKey: "message") ?? "パスワードを入力してください"
    @State private var keyPass = UserDefaults.standard.string(forKey: "pass") ?? ""
    @State var errorMessage = ""
    @State private var isUnlocked = false
    @State private var biometrics = "faceid"
    @State private var biometricscolor: Color = Color.blue
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    @State var showClearButton = true
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text(self.titleMessage).font(.headline)
                Text(self.errorMessage).foregroundColor(.red)
                SecureField("パスワードを入力", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.top, .leading, .trailing])
                HStack {
                    if UserDefaults.standard.string(forKey: "message") != "新しいパスワードを入力してください" {
                        if showClearButton {
                            Image(systemName: self.biometrics)
                                .animation(.easeInOut(duration: 200))
                                .foregroundColor(self.biometricscolor)
                                .font(.title)
                                .onTapGesture {
                                    impactMed.impactOccurred()
                                    authenticate()
                                    self.showClearButton = false
                                }
                        } else {
                            Image(systemName: "faceid")
                                .animation(.easeInOut(duration: 200))
                                .foregroundColor(.green)
                                .font(.title)
                                .rotationEffect(Angle(degrees: 360.0))
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .animation(.easeInOut(duration: 2))
                            .foregroundColor(.yellow)
                            .font(.title)
                    }
                    Button(action: {
                        UserDefaults.standard.set("yes", forKey: "Taps")
                        if self.password == "" {
                            if UserDefaults.standard.string(forKey: "message") != "新しいパスワードを入力してください" {
                                self.errorMessage = "入力してください"
                                self.generator.notificationOccurred(.error)
                                self.isUnlocked = false
                            } else {
                                self.errorMessage = "パスワードは1文字以上である必要があります"
                                self.generator.notificationOccurred(.error)
                                self.isUnlocked = false
                            }
                        } else if self.keyPass == self.password {
                            UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: {})
                            print("done with", self.password)
                            self.isUnlocked = true
                        } else if self.keyPass == "" {
                            UserDefaults.standard.set(self.password, forKey: "pass")
                            UserDefaults.standard.set("パスワードを入力してください", forKey: "message")
                            UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: {})
                            self.isUnlocked = true
                        } else {
                            self.errorMessage = "パスワードが一致しません"
                            self.generator.notificationOccurred(.error)
                            self.isUnlocked = false
                        }
                    }) {
                        Text("完了")
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(minWidth: 250)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.accentColor)
                            .cornerRadius(8)
                            .onTapGesture {
                                impactMed.impactOccurred()
                                UserDefaults.standard.set("yes", forKey: "Taps")
                                if self.password == "" {
                                    if UserDefaults.standard.string(forKey: "message") != "新しいパスワードを入力してください" {
                                        self.errorMessage = "入力してください"
                                        self.generator.notificationOccurred(.error)
                                        self.isUnlocked = false
                                    } else {
                                        self.errorMessage = "パスワードは1文字以上である必要があります"
                                        self.generator.notificationOccurred(.error)
                                        self.isUnlocked = false
                                    }
                                } else if self.keyPass == self.password {
                                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: {})
                                    print("done with", self.password)
                                    self.isUnlocked = true
                                } else if self.keyPass == "" {
                                    UserDefaults.standard.set(self.password, forKey: "pass")
                                    UserDefaults.standard.set("パスワードを入力してください", forKey: "message")
                                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: {})
                                    self.isUnlocked = true
                                } else {
                                    self.errorMessage = "パスワードが一致しません"
                                    self.generator.notificationOccurred(.error)
                                    self.isUnlocked = false
                                }
                            }
                    }
                    .padding(.top, 3.0)
                    .padding(.horizontal)
                    
                    Button(action: {
                        self.password = ""
                        selectionFeedback.selectionChanged()
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(Color.accentColor)
                            .font(.system(size: 20))
                    }
                }
                Spacer()
            }
            .padding(.top)
            .onAppear {
                self.viewController?.isModalInPresentation = true
                if UserDefaults.standard.string(forKey: "message") != "新しいパスワードを入力してください" {
                    authenticate()
                }
            }
        }
    }
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if context.biometryType == .faceID {
                self.biometrics = "faceid"
                self.biometricscolor = Color.blue
            } else if context.biometryType == .touchID {
                self.biometrics = "touchid"
                self.biometricscolor = Color.red
            } else {
                self.biometrics = "ipod"
                self.biometricscolor = Color.gray
            }
        }
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "情報の保護に利用します。"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                        impactMed.impactOccurred()
                        UserDefaults.standard.set("yes", forKey: "Taps")
                        if self.isUnlocked == true {
                            UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: {})
                            print("done with", self.password)
                            self.isUnlocked = true
                        }
                    } else {
                        self.isUnlocked = false
                        self.generator.notificationOccurred(.error)
                        self.showClearButton = true
                    }
                }
            }
        } else {
            self.isUnlocked = false
        }
    }
}

struct ViewControllerHolder {
    weak var value: UIViewController?
    init(_ value: UIViewController?) {
        self.value = value
    }
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        guard var visibleViewController = UIApplication.shared.windows.first?.rootViewController else {
            return ViewControllerHolder(nil)
        }
        while let vc = visibleViewController.presentedViewController {
            visibleViewController = vc
        }
        return ViewControllerHolder(visibleViewController)
    }
}

extension EnvironmentValues {
    var viewController: ViewControllerHolder {
        get {
            return self[ViewControllerKey.self]
        }
        set {
            self[ViewControllerKey.self] = newValue
        }
    }
}

extension UIViewController {
    func present<Content: View>(
        presentationStyle: UIModalPresentationStyle = .automatic,
        transitionStyle: UIModalTransitionStyle = .coverVertical,
        animated: Bool = true,
        backgroundColor: UIColor = .clear,
        completion: @escaping () -> Void = {},
        @ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, ViewControllerHolder(toPresent))
        )
        toPresent.modalPresentationStyle = presentationStyle
        toPresent.modalTransitionStyle = transitionStyle
        self.present(toPresent, animated: animated, completion: completion)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
