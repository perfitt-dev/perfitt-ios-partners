//
//  PerfittBridgeJavaScript.swift
//  Pods
//
//  Created by nick on 2021/02/18.
//
import WebKit

public class PerfittBridgeJavaScript: NSObject, WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // PERFITT_SDK ( KIT )
        if (message.name == PerfittPartners.instance.contentKit) {
            PerfittPartners.instance.status = .Kit
            self.showSizePicker()
        }
        // PERFITT_SDK ( A4 )
        else if (message.name == PerfittPartners.instance.contentA4) {
            PerfittPartners.instance.status = .A4
            self.showSizePicker()
        }
    }
}

extension PerfittBridgeJavaScript {
    private func showSizePicker() {
        let sizePicker = SizePicker.initViewController(viewControllerClass: SizePicker.self)
        sizePicker.delegate = SizePickerController()
        sizePicker.modalPresentationStyle = .overCurrentContext
        
        PerfittPartners.instance.ownerViewController?.present(sizePicker, animated: true, completion: nil)
    }
}

