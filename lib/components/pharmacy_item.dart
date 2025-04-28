import 'package:flutter/material.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';

class PharmacyItem extends StatelessWidget {
  final Result pharmacy;
  final VoidCallback onTap;

  const PharmacyItem({
    super.key,
    required this.pharmacy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              pharmacy.name?.toUpperCase() ?? 'İSİM YOK',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Icon(
                  Icons.location_on,
                  size: 22,
                  color:  Colors.redAccent.shade400
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    pharmacy.address ?? 'Adres belirtilmemiş',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: [
                 Icon(
                  Icons.access_time,
                  size: 22,
                  color: Colors.redAccent.shade400
                ),
                const SizedBox(width: 10),
                Text(
                  'Nöbet Zamanı Bilgisi Yok',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Arama özelliği (${pharmacy.phone ?? 'Numara Yok'}) yakında!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all( 
                        color: Colors.redAccent.shade700,
                        width: 0.75,
                        
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          color:  Colors.redAccent.shade700,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Ara',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Yön tarifi (${pharmacy.loc ?? 'Konum Yok'}) yakında!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration:  BoxDecoration(
                      color: Colors.white,
                      border: Border.all( 
                        color: Colors.redAccent.shade700,
                        width: 0.75,
                        
                      ),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions,
                          color:  Colors.redAccent.shade700,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Yön Tarifi',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}