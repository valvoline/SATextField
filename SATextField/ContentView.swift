//
//  ContentView.swift
//  Representable1
//
//  Created by valvoline on 26/06/2019.
//  Copyright © 2019 Costantino Pistagna. All rights reserved.
//

import SwiftUI
import UIKit

//struct ViewControllerWrapper: UIViewControllerRepresentable {
//    var controller: UIViewController
//    @Binding var keyboardActive:Bool
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        if context.coordinator.isKeyboardShown == true, keyboardActive == false {
//            uiViewController.view.endEditing(true)
//        } else {
//            keyboardActive = context.coordinator.isKeyboardShown
//        }
//        uiViewController.view.backgroundColor = UIColor.red
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject {
//        var isKeyboardShown: Bool = false
//        var parent: ViewControllerWrapper
//
//        init(_ viewController: ViewControllerWrapper) {
//            self.parent = viewController
//            super.init()
//
//            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: OperationQueue.main)
//            { (notification) in
//                self.isKeyboardShown = true
//            }
//            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: OperationQueue.main)
//            { (notification) in
//                self.isKeyboardShown = false
//            }
//        }
//    }
//}
//
//struct ViewController<Page: View>: View {
//    @Binding var keyboardActive:Bool
//    var viewController: UIHostingController<Page>
//
//    init(_ view: Page, keyboardActive: Binding<Bool>) {
//        self.viewController = UIHostingController(rootView: view)
//        self.$keyboardActive = keyboardActive
//    }
//
//    var body: some View {
//        ViewControllerWrapper(controller: viewController, keyboardActive: $keyboardActive)
//    }
//}
//
//
class WrappableTextField: UITextField, UITextFieldDelegate {
    var textFieldChangedHandler: ((String)->Void)?
    var onCommitHandler: (()->Void)?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentValue = textField.text as NSString? {
            let proposedValue = currentValue.replacingCharacters(in: range, with: string)
            textFieldChangedHandler?(proposedValue as String)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        onCommitHandler?()
    }
}

struct SATextField: UIViewRepresentable {
    private let tmpView = WrappableTextField()

    //var exposed to SwiftUI object init
    var tag:Int = 0
    var placeholder:String?
    var changeHandler:((String)->Void)?
    var onCommitHandler:(()->Void)?
    
    func makeUIView(context: UIViewRepresentableContext<SATextField>) -> WrappableTextField {
        tmpView.tag = tag
        tmpView.delegate = tmpView
        tmpView.placeholder = placeholder
        tmpView.onCommitHandler = onCommitHandler
        tmpView.textFieldChangedHandler = changeHandler
        return tmpView
    }
    
    func updateUIView(_ uiView: WrappableTextField, context: UIViewRepresentableContext<SATextField>) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}

struct ContentView : View {
    @State var username:String = ""
    @State var email:String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text(username)
                Spacer()
                Text(email)
            }
            SATextField(tag: 0, placeholder: "@username", changeHandler: { (newString) in
                self.username = newString
            }, onCommitHandler: {
                print("commitHandler")
            }).padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)).background(Color.red)
            SATextField(tag: 1, placeholder: "@email", changeHandler: { (newString) in
                self.email = newString
            }, onCommitHandler: {
                print("commitHandler")
            }).padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)).background(Color.red)
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
