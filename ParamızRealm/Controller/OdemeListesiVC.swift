//
//  OdemeListesiVC.swift
//  ParamızRealm
//
//  Created by Erkan on 24.12.2022.
//

import UIKit
import RealmSwift

class OdemeListesiVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var odemeListesi : Results<Odeme>?
    var secilenAktivite : Aktivite?{
        didSet{
            //eğer bir değer atanırsa bunu çalıştır
            odemeleriYukle()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return odemeListesi?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hucre = tableView.dequeueReusableCell(withIdentifier: "odemeCell", for: indexPath)
        if let odeme = odemeListesi?[indexPath.row]{
            hucre.textLabel?.text = ("\(odeme.odeyeninAdi) - \(odeme.miktar) lira")
        }else{
            hucre.textLabel?.text = "Henüz Eklenen Bir Ödeme Bulunumadı"
        }
        return hucre
    }
    @IBAction func odemeClicked(_ sender: UIBarButtonItem) {
        
        let alerController = UIAlertController(title: "Ödeme Ekle", message: "Ödenecek değeri Ekleyiniz", preferredStyle: .alert)
        alerController.addTextField{txtKisiAdi in
            txtKisiAdi.placeholder = "Odeyen Kişi"
        }
        alerController.addTextField{txtAciklama in
            txtAciklama.placeholder = "Açıklama"
        }
        alerController.addTextField{txtUcret in
            txtUcret.placeholder = "Ücret"
            txtUcret.keyboardType = .numberPad
        }
        
        let add = UIAlertAction(title: "Ekle", style: .default){action in
            let txtKisi = alerController.textFields![0]
            let txtAciklama = alerController.textFields![1]
            let txtUcret = alerController.textFields![2]
            
            if let secilenAktivite = self.secilenAktivite{  // eğer secilen aktivite herhangi veri varsa ekle
                do{
                    try self.realm.write{
                        let yeniOdeme = Odeme()
                        yeniOdeme.odeyeninAdi = txtKisi.text ?? "Girilmedi"
                        yeniOdeme.aciklama = txtAciklama.text ?? "Girilmedi"
                        yeniOdeme.miktar = Int(txtUcret.text ?? "-1")!
                        secilenAktivite.odemeler.append(yeniOdeme)
                    }
                }catch{
                    print("Odeme eklerken hata meydana geldi \(error.localizedDescription)")
                }
            }
            self.tableView.reloadData()
            
        }
        
        alerController.addAction(add)
        present(alerController, animated: true, completion: nil)
    }
    
    func odemeleriYukle(){
        odemeListesi = secilenAktivite?.odemeler.sorted(byKeyPath: "odeyeninAdi", ascending: true)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "odemeDuzenleSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "odemeDuzenleSegue"{
            let hedefVC = segue.destination as! OdemeDuzenleVC
            if let seciliIndex = tableView.indexPathForSelectedRow{
                if let secilenOdeme = odemeListesi?[seciliIndex.row]{
                    hedefVC.secilenOdeme = secilenOdeme
                    hedefVC.secilenAktivite = secilenAktivite
                    hedefVC.title = "\(secilenOdeme.odeyeninAdi) Ödeme Bilgileri"
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if let secilenOdeme = odemeListesi?[indexPath.row]{
                do{
                    try realm.write{
                        realm.delete(secilenOdeme)
                        print("SECİLEN ODEME BAŞARIYLA SİLİNDFİ")
                    }
                }catch{
                        print("Hata meydana geldi \(error.localizedDescription)")
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if odemeListesi?.count == 0{
            odemeleriYukle()
            
        }
        odemeListesi = odemeListesi?.filter("odeyeninAdi == %@",searchBar.text!).sorted(byKeyPath: "odeyeninAdi", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            odemeleriYukle()
        }
       /*DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }*/
    }
    
}
