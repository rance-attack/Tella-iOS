//
//  FileManager.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/25/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//


/*
 Wraps up file manipulation functions up safely using a static singleton.
 */
import Foundation
import UIKit

struct TellaFileManager {

    // Singleton file manager instance
    private static let instance = FileManager.default
    static let rootDir = "\(NSHomeDirectory())/Documents"
    private static let keyFolderPath = "\(rootDir)/keys"
    private static let encryptedFolderPath = "\(rootDir)/files"
    private static let fileNameLength = 8

    // Initializes directories for the keys and files.
    static func initDirectories() {
        initDirectory(keyFolderPath)
        initDirectory(encryptedFolderPath)
    }

    // Removes all files associated with the user.
    static func clearAllFiles() {
        getEncryptedFileNames().forEach { name in
            deleteEncryptedFile(name: name)
        }
        deleteKeyFile(.PUBLIC)
        deleteKeyFile(.PRIVATE)
        deleteKeyFile(.META_PUBLIC)
        let err: ()? = try? CryptoManager.deleteMetaKeypair()
        if err != nil {
            print("could not delete private meta key from enclave")
        }
    }

    // Safely initializes a directory and quits the app if it fails.
    private static func initDirectory(_ atPath: String) {
        if !instance.fileExists(atPath: atPath) {
            do {
                try instance.createDirectory(atPath: atPath, withIntermediateDirectories: true)
            } catch let error {
                print("Error: \(error.localizedDescription)")
                // Quits app because initialization failed
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                return
            }
        }
    }

    static func saveTextFile(_ text: String) {
        saveFile(text.data(using: String.Encoding.utf8)!, FileTypeEnum.TEXT.rawValue)
    }

    static func saveImage(_ image: UIImage) {
        if let fixed = image.fixedOrientation() {
            if let pngData = fixed.pngData() {
                saveFile(pngData, FileTypeEnum.IMAGE.rawValue)
            }
        }
    }

    private static func saveFile(_ data: Data, _ type: String) {
        var foundNewName = false
        var newName = getRandomFilename(type)
        while !foundNewName {
            if !instance.fileExists(atPath: "\(encryptedFolderPath)/\(newName)") {
                foundNewName = true
            } else {
                newName = getRandomFilename(type)
            }
        }
        if let encrypted = CryptoManager.encryptUserData(data) {
            instance.createFile(atPath: "\(encryptedFolderPath)/\(newName)", contents: encrypted)
        } else {
            print("encryption failed")
        }
    }

    static func copyExternalFile(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            saveFile(data, url.pathExtension)
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }

    static func recoverImage(_ data: Data?) -> UIImage? {
        if let unwrapped = data {
            return UIImage(data: unwrapped)
        }
        return nil
    }

    static func recoverText(_ data: Data?) -> String? {
        if let unwrapped = data {
            return String(data: unwrapped, encoding: String.Encoding.utf8)
        }
        return nil
    }

    static func recoverAndDecrypt(_ atPath: String, _ privKey: SecKey) -> Data? {
        if let data = recoverData(atPath) {
            if let decrypted = CryptoManager.decrypt(data, privKey) {
                return decrypted
            }
        }
        return nil
    }

    static func recoverData(_ atPath: String) -> Data? {
        return instance.contents(atPath: atPath)
    }

    static func getEncryptedFileNames() -> [String] {
        do {
            let arrDirContent = try instance.contentsOfDirectory(atPath: encryptedFolderPath)
            return arrDirContent
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return []
        }
    }

    static func fileNameToPath(name: String) -> String {
        return "\(encryptedFolderPath)/\(name)"
    }

    private static func getRandomFilename(_ type: String) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<TellaFileManager.fileNameLength).map{ _ in letters.randomElement()! }) + "." + type
    }


    static func deleteEncryptedFile(name: String) {
        do {
            try instance.removeItem(atPath: "\(encryptedFolderPath)/\(name)")
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }

    //function called for the renaming feature
    //automatically handles checking for the same name and won't rename a file if there is already a file with the same name
    static func rename(original: String, new: String, type: String) -> Bool {
        do {
            print(new)
            try instance.moveItem(atPath: original, toPath: self.fileNameToPath(name: new + "." + type))
        } catch let error{
            print("error: \(error.localizedDescription)")
            return false
        }
        return true
    }

    static func keyFileExists(_ type: KeyFileEnum) -> Bool {
        return instance.fileExists(atPath: type.toPath())
    }

    static func saveKeyData(_ data: Data, _ type: KeyFileEnum) {
        instance.createFile(atPath: type.toPath(), contents: data)
    }

    static func recoverKeyData(_ type: KeyFileEnum) -> Data? {
        return recoverData(type.toPath())
    }

    static func deleteKeyFile(_ type: KeyFileEnum) {
        if instance.fileExists(atPath: type.toPath()) {
            do {
                try instance.removeItem(atPath: type.toPath())
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        } else {
            print("\(type.rawValue) did not exist")
        }
    }

}
