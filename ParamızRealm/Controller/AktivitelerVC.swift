//
//  AktivitelerVC.swift
//  ParamızRealm
//
//  Created by Erkan on 23.12.2022.
//

import UIKit
import RealmSwift

class AktivitelerVC: UITableViewController, UISearchBarDelegate {


    @IBOutlet weak var searchBar: UISearchBar!
    var aktivitelerListesi : Results<Aktivite>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        


        
 
        verileriYukle()
        searchBar.delegate = self

    }
    /*func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else{
            return
        }
        print(text)
    }*/

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return aktivitelerListesi?.count ?? 1  // eğer nil dğer döndürürse 1 i döndür
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "aktiviteCell")
        //cell.textLabel?.text = aktivitelerListesi?[indexPath.row].adi ?? "Aktivite Bulunumadi"
        let sonuc : Int = aktivitelerListesi?[indexPath.row].odemeler.sum(ofProperty: "miktar") ?? 0
        if let adi = aktivitelerListesi?[indexPath.row].adi{
            cell.textLabel?.text = "\(adi) - \(sonuc)"
        }else{
            cell.textLabel?.text = "Aktivite Bulunumadı"
        }
        if aktivitelerListesi?[indexPath.row].Bittimi ?? false{
            cell.backgroundColor = UIColor.darkGray
            cell.textLabel?.textColor = UIColor.white
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*//let secilenHucre = tableView.cellForRow(at: indexPath)
        aktivitelerListesi[indexPath.row].Bittimi = !aktivitelerListesi[indexPath.row].Bittimi

       /* if secilenHucre?.accessoryType == UITableViewCell.AccessoryType.checkmark{
            secilenHucre?.accessoryType = .none
        }else{
            secilenHucre?.accessoryType = .checkmark
        }*/
        tableView.reloadData() // cell for row at tekrar çalışacak ve bütün satırlar tekrar oluşacak
        */
        performSegue(withIdentifier: "odemeListesiSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "odemeListesiSegue"{
            let hedefVC = segue.destination as! OdemeListesiVC
            if let seciliIndex = tableView.indexPathForSelectedRow{
                hedefVC.secilenAktivite = aktivitelerListesi?[seciliIndex.row]
            }
        }
    }
    

   
    @IBAction func ekleTiklandi(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Aktivite Ekle", message: "Eklemek İstediğiniz aktivite", preferredStyle: .alert)
        alertController.addTextField{ txtAktiviteAdi in
            txtAktiviteAdi.placeholder = "Aktivite Adı"
        }
        let ekleAction = UIAlertAction(title: "Ekle", style: .default){action in
            let txtAktiviteAdi = alertController.textFields![0]
            
            if !txtAktiviteAdi.text!.isEmpty{ // Eğer boş değilse
                let a1 = Aktivite()
                a1.adi = txtAktiviteAdi.text!
                //self.aktivitelerListesi.append(txtAktiviteAdi.text!)
                //.aktivitelerListesi.append(a1)
                //self.veriler.set(self.aktivitelerListesi, forKey: "AktiviteListesi")
                self.verileriKaydet(aktivite: a1)
                self.tableView.reloadData()
            }
            
        }
        
        
        let cancelAction = UIAlertAction(title: "Vazgeç", style: .cancel)
        
        alertController.addAction(ekleAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    func verileriKaydet(aktivite : Aktivite){
        do{
            try realm.write{
                realm.add(aktivite)
            }
        }catch{
            
        }
    }
    
    func verileriYukle(){
        aktivitelerListesi = realm.objects(Aktivite.self)
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /*override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if let silinecekAktivite = aktivitelerListesi?[indexPath.row]{
                do{
                    try realm.write{
                        realm.delete(silinecekAktivite.odemeler)
                        realm.delete(silinecekAktivite)
                    }
                }catch{
                    print("Aktivite silinemedi \(error.localizedDescription)")
                }
            }
        }
        tableView.reloadData()
    }*/
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        aktivitelerListesi = aktivitelerListesi?.filter("adi CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "adi", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            verileriYukle()   // kullanıcının girdiği bir değer yok ozaman tüm verileri yükle
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()   // kullanıcı tüm değerleri sildiğinde klavye yok olacak
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let silme = UITableViewRowAction(style: .default, title: "Sil") { (action, indexPath) in
            if let silinecekAktivite = self.aktivitelerListesi?[indexPath.row]{
                do{
                    try self.realm.write{
                        self.realm.delete(silinecekAktivite.odemeler)
                        self.realm.delete(silinecekAktivite)
                    }
                }catch{
                    print("Aktivite silinemedi \(error.localizedDescription)")
                }
            }
            tableView.reloadData()
        }
        let odeme = UITableViewRowAction(style: .normal, title: "Ödeme"){ (action, indexPath) in
            
            if let aktivite = self.aktivitelerListesi?[indexPath.row]{
                do{
                    try self.realm.write{
                        aktivite.Bittimi = true
                        print("Aktivitede ödeşme yapıldı")
                    }
                }catch{
                    print("Ödemede hata meydana geldi")
                }
            }
            tableView.reloadData()
            
        }
        odeme.backgroundColor = .green
        return[odeme,silme]
    }
    
}




//VERİLERİ PLİSTE KAYDEDER
/*func verileriKaydet(){
    do{
        let data = try PropertyListEncoder().encode(self.aktivitelerListesi)  // verileri encode ederek pliste aktardık
        try data.write(to: self.dosyaYolu)
    }catch{
        print("Veriler kaydedilirken hata oluştu \(error.localizedDescription)")
    }
}
//VERİLERİ PLİSTTEN ÇEKER
func verileriYukle(){
    if let veri = try? Data(contentsOf: dosyaYolu){
        do{
            aktivitelerListesi = try PropertyListDecoder().decode([Aktivite].self, from: veri)
        }catch{
            print("Verileri Getirirken Hata meydana geldi: \(error.localizedDescription)")
        }
    }
}*/
