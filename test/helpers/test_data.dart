import 'package:company_info_explorer/domain/entities/company.dart';

const testCompany1 = Company(
  stockCode: '1101',
  name: '臺灣水泥股份有限公司',
  shortName: '台泥',
  industryCode: '01',
  chairman: '張安平',
  generalManager: '張安平',
  address: '台北市中山北路2段113號',
  phone: '(02)2531-7099',
  taxId: '11913502',
  foundedDate: '19501229',
  listedDate: '19620209',
  paidInCapital: 73561817420,
  parValueDesc: '新台幣 10.0000元',
  parValue: 10.0,
  specialShares: 0,
  privateShares: 0,
  website: 'https://www.taiwancement.com',
);

const testCompany2 = Company(
  stockCode: '1102',
  name: '亞洲水泥股份有限公司',
  shortName: '亞泥',
  industryCode: '01',
  chairman: '徐旭東',
  generalManager: '李坤炎',
  address: '台北市民生東路1段27號',
  phone: '(02)2521-7271',
  taxId: '03706301',
  foundedDate: '19570209',
  listedDate: '19620209',
  paidInCapital: 33646617490,
  parValueDesc: '新台幣 10.0000元',
  parValue: 10.0,
  specialShares: 0,
  privateShares: 0,
  website: 'https://www.acc.com.tw',
);

const testCompany3 = Company(
  stockCode: '2330',
  name: '台灣積體電路製造股份有限公司',
  shortName: '台積電',
  industryCode: '24',
  chairman: '魏哲家',
  generalManager: '魏哲家',
  address: '新竹市新竹科學工業園區力行六路8號',
  phone: '(03)563-6688',
  taxId: '22099131',
  foundedDate: '19870221',
  listedDate: '19940905',
  paidInCapital: 259303804580,
  parValueDesc: '新台幣 10.0000元',
  parValue: 10.0,
  specialShares: 0,
  privateShares: 0,
  website: 'https://www.tsmc.com',
);

final testCompanies = [testCompany1, testCompany2, testCompany3];
