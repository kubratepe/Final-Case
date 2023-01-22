// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MedicineTracking {
    struct Medicine {   // İlaç özelliklerinin tutulduğu bir Medicine yapısı oluşturuldu
        string name;    // string tipinde ilaç ismini tutar
        uint batchNumber;  // uint tipinde ilacın parti numarasını tutar 
        uint expiryDate;   // uint tipinde ilacın son kullanma tarihini tutar
        address manufacturer;  // Üreticinin adresini tutar
        address distributor;   // Dağıtıcının adresini tutar
        address retailer;      // Perakendecinin adresinin tutar
        address consumer;      // Tüketicinin adresini tutar
    }
    mapping(uint => Medicine) public medicines;
    uint public medicineCount;  // Kayıtlı olan ilaçların sayısını tutar

    event MedicineAdded(uint indexed batchNumber);  // İlaç eklendiğinde gerçekleşen olay
    event MedicineTransferred(uint indexed batchNumber, address indexed from, address indexed to);  // İlaç transferinde hangi parti numaralı ilacın, hangi adresten diğer adrese gönderileceğini tutan olay

    constructor() public {      // Bu yapı sözleşmenin başında bir defa çalıştırılır ve ilaç sayısını sıfır yapar
        medicineCount = 0;
    }

    function addMedicine(string memory _name, uint _batchNumber, uint _expiryDate, address _manufacturer) public {  // İlaç ekleme fonksiyonudur ve parametre olarak yeni ilaç eklerken girilmesi istenen bilgileri tutar
        require(_batchNumber > 0);  
        require(_expiryDate > block.timestamp);  // Son kullanma tarihinin geçmemiş olması gereksinimini belirtir
        require(_manufacturer != address(0));

        medicines[medicineCount] = Medicine(_name, _batchNumber, _expiryDate, _manufacturer, address(0), address(0), address(0));
        medicineCount++;  // İlaç sayısını 1 artırır

        emit MedicineAdded(_batchNumber);  // İlaç eklendiğinde çalıştırılan ve ilacın parti numarasını tutan olay

    }

    function transferMedicine(uint _batchNumber, address _to) public {
        require(_batchNumber > 0);
        require(_to != address(0));

        Medicine storage medicine = medicines[_batchNumber]; 
        require(medicine.batchNumber == _batchNumber);  // Parti numaralarının aynı olması gerekliliğini belirtir

        address from;
        if (medicine.manufacturer == msg.sender) {   // Eğer ürünü transfer eden üretici ise, üreticinin adresi sıfırlanır ve adres dağıtıcıya atanır
            medicine.manufacturer = address(0);
            medicine.distributor = _to;
            from = medicine.manufacturer;
        } else if (medicine.distributor == msg.sender) {  // Eğer ürünü transfer eden dağıtıcı ise, dağıtıcının adresi sıfırlanır ve adres perakendeciye atanır
            medicine.distributor = address(0);
            medicine.retailer = _to;
            from = medicine.distributor;
        } else if (medicine.retailer == msg.sender) {   // Eğer ürünü transfer eden perakendeci ise, perakendecinin adresi sıfırlanır ve adres tüketiciye atanır
            medicine.retailer = address(0);
            medicine.consumer = _to;
            from = medicine.retailer;
        } else {
            revert();
        }

        emit MedicineTransferred(_batchNumber, from, _to);  // Adres değişikliğinin yapıldığı olayı belirtir
    }

    function viewMedicineDetails(uint _batchNumber) public view returns (string memory, uint, uint, address, address, address, address) {  // İlaç bilgilerinin gösteren fonksiyon tanımlandı
        require(_batchNumber > 0);

        Medicine storage medicine = medicines[_batchNumber];
        require(medicine.batchNumber == _batchNumber);

        return (medicine.name, medicine.batchNumber, medicine.expiryDate, medicine.manufacturer, medicine.distributor, medicine.retailer, medicine.consumer);  // İlaç bilgilerini döndürür
    }
}