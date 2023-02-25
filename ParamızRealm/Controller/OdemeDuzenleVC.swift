//
//  OdemeDuzenleVC.swift
//  ParamızRealm
//
//  Created by Erkan on 24.12.2022.
//

import UIKit
import RealmSwift
class OdemeDuzenleVC: UIViewController {

    
    
    let realm = try! Realm()
    var secilenAktivite : Aktivite?
    var secilenOdeme : Odeme?
    
    @IBOutlet weak var lblToplamOdeme: UILabel!
    @IBOutlet weak var lblAktiviteAdi: UILabel!
    @IBOutlet weak var txtUcret: UITextField!
    @IBOutlet weak var txtAdi: UITextField!
    @IBOutlet weak var txtAciklama: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gorunumuAyarla()
    }
    


    @IBAction func guncelleClicked(_ sender: UIButton) {
        if let secilenOdeme = secilenOdeme{   //referans tipi oldugu için realm spesifik olarak bir güncellemesi yok realmın
            do{
                try  realm.write{
                    secilenOdeme.odeyeninAdi = txtAdi.text!
                    secilenOdeme.aciklama = txtAciklama.text!
                    secilenOdeme.miktar = Int(txtUcret.text!)!
                    print("ODEME BAŞARIYLA GUNCELLENDİ")
                }
            }catch{
                print("Odeme güncellenirken hata \(error.localizedDescription)")
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    
    func gorunumuAyarla(){
        txtAdi.text = secilenOdeme?.odeyeninAdi
        txtAciklama.text = secilenOdeme?.aciklama
        txtUcret.text = "\(secilenOdeme!.miktar)"
        
        lblAktiviteAdi.text = "Aktivite Adı : \(secilenAktivite!.adi)"
        
        let toplamOdeme = secilenAktivite?.odemeler.filter("odeyeninAdi == %@",secilenOdeme?.odeyeninAdi).sum(ofProperty: "miktar") ?? 0
        lblToplamOdeme.text = "Yaptığı toplam ödeme: \(toplamOdeme)"
        
        var verim = NSMutableAttributedString(string: "Aktivite Adı :", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)])
        verim.append(NSAttributedString(string: "\(secilenAktivite!.adi)", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor : UIColor.red]))
        lblAktiviteAdi.attributedText = verim
    }
    
}
