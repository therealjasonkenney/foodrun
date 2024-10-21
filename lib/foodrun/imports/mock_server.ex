defmodule Foodrun.Imports.MockServer do
  @moduledoc false

  use Plug.Router

  # plug Plug.Parsers

  plug :match
  plug :dispatch

  get "/test.csv" do
    conn
    |> Plug.Conn.put_resp_content_type("text/csv; charset=utf-8")
    |> Plug.Conn.put_resp_header("Content-disposition", "attachment; filename=test.csv")
    |> Plug.Conn.send_resp(200, file())
  end

  defp file() do
    """
    locationid,Applicant,FacilityType,cnn,LocationDescription,Address,blocklot,block,lot,permit,Status,FoodItems,X,Y,Latitude,Longitude,Schedule,dayshours,NOISent,Approved,Received,PriorPermit,ExpirationDate,Location,Fire Prevention Districts,Police Districts,Supervisor Districts,Zip Codes,Neighborhoods (old)
    1514024,F & C Catering,Truck,0,,Assessors Block /Lot,,,,21MFF-00035,EXPIRED,Cold Truck: Hot/Cold Sandwiches: Water: Soda: Juice: Snacks: Milk: Candies: Canned Food: Soups: Cup of Noodles: Fruit: Salad,,,0,0,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=21MFF-00035&ExportPDF=1&Filename=21MFF-00035_schedule.pdf,,,03/30/2021 12:00:00 AM,20210326,1,11/15/2021 12:00:00 AM,"(0.0, 0.0)",,,,,
    1658389,BH & MT LLC,Truck,1232000,,401 23RD ST,4232010,4232,010,22MFF-00059,EXPIRED,Cold Truck: Breakfast: Sandwiches: Salads: Pre-Packaged Snacks: Beverages,6016887.317,2102871.037,37.755030726766726,-122.38453073422282,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=22MFF-00059&ExportPDF=1&Filename=22MFF-00059_schedule.pdf,,,11/08/2022 12:00:00 AM,20221108,1,11/15/2023 12:00:00 AM,"(37.755030726766726, -122.38453073422282)",10,3,8,28856,29
    1723797,Natan's Catering,Truck,0,,Assessors Block 4058/Lot010,4058010,4058,010,23MFF-00006,APPROVED,Burgers: melts: hot dogs: burritos:sandwiches: fries: onion rings: drinks,6015895.442,2105131.652,37.761182994505084,-122.38811870407658,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=23MFF-00006&ExportPDF=1&Filename=23MFF-00006_schedule.pdf,,,09/12/2023 12:00:00 AM,20230911,1,11/15/2024 12:00:00 AM,"(37.761182994505084, -122.38811870407658)",10,3,8,28856,29
    1336731,Quan Catering,Truck,15086000,,3305 03RD ST,4502A002,4502A,002,19MFF-00055,EXPIRED,Cold Truck: Soft drinks: cup cakes: potato chips: cookies: gum: sandwiches (hot & cold): peanuts: muffins: coff (hot & cold): water: juice: yoplait: milk: orange juice: sunflower seeds: can foods: burritos: buscuits: chimichangas: rice krispies,6018751.714,2098754.754,37.74383117213268,-122.37779736896212,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=19MFF-00055&ExportPDF=1&Filename=19MFF-00055_schedule.pdf,,,07/10/2019 12:00:00 AM,20190710,1,01/15/2021 12:00:00 AM,"(37.74383117213268, -122.37779736896212)",10,3,8,58,1
    1723795,Natan's Catering,Truck,0,,Assessors Block 7295/Lot022,7295022,7295,022,23MFF-00006,APPROVED,Burgers: melts: hot dogs: burritos:sandwiches: fries: onion rings: drinks,5989624.724,2094318.981,37.730003683189196,-122.4781863254146,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=23MFF-00006&ExportPDF=1&Filename=23MFF-00006_schedule.pdf,,,09/12/2023 12:00:00 AM,20230911,1,11/15/2024 12:00:00 AM,"(37.730003683189196, -122.4781863254146)",1,8,4,64,14
    1723794,Natan's Catering,Truck,0,,Assessors Block 5598/Lot031,5598031,5598,031,23MFF-00006,APPROVED,Burgers: melts: hot dogs: burritos:sandwiches: fries: onion rings: drinks,6010555.36796,2097635.85527,37.74030387280596,-122.4060597434942,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=23MFF-00006&ExportPDF=1&Filename=23MFF-00006_schedule.pdf,,,09/12/2023 12:00:00 AM,20230911,1,11/15/2024 12:00:00 AM,"(37.74030387280596, -122.4060597434942)",10,3,8,58,1
    1723802,Natan's Catering,Truck,0,,Assessors Block 4103/Lot023A,4103023A,4103,023A,23MFF-00006,APPROVED,Burgers: melts: hot dogs: burritos:sandwiches: fries: onion rings: drinks,6014314.885,2104114.856,37.758303395642486,-122.39351405481675,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=23MFF-00006&ExportPDF=1&Filename=23MFF-00006_schedule.pdf,,,09/12/2023 12:00:00 AM,20230911,1,11/15/2024 12:00:00 AM,"(37.758303395642486, -122.39351405481675)",10,3,8,28856,29
    1723809,Natan's Catering,Truck,185205,,1650 03RD ST,8711007,8711,007,23MFF-00006,APPROVED,Burgers: melts: hot dogs: burritos:sandwiches: fries: onion rings: drinks,6014983.88328,2108042.28534,37.769124412168054,-122.39147491124585,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=23MFF-00006&ExportPDF=1&Filename=23MFF-00006_schedule.pdf,,,09/12/2023 12:00:00 AM,20230911,1,11/15/2024 12:00:00 AM,"(37.769124412168054, -122.39147491124585)",14,3,9,310,20
    1723798,Natan's Catering,Truck,0,,Assessors Block 4227/Lot012,4227012,4227,012,23MFF-00006,APPROVED,Burgers: melts: hot dogs: burritos:sandwiches: fries: onion rings: drinks,6014953.292,2102226.967,37.75315510671546,-122.3911741844557,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=23MFF-00006&ExportPDF=1&Filename=23MFF-00006_schedule.pdf,,,09/12/2023 12:00:00 AM,20230911,1,11/15/2024 12:00:00 AM,"(37.75315510671546, -122.3911741844557)",10,3,8,28856,29
    """
  end
end
