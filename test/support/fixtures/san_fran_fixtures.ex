defmodule Foodrun.SanFranFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Foodrun.FoodTrucks` context.
  """

  @doc """
  Generate a csv stream
  """
  def san_fran_stream_fixture() do
    content = [
      "locationid,Applicant,FacilityType,cnn,LocationDescription,Address,blocklot,block,lot,permit,Status,FoodItems,X,Y,Latitude,Longitude,Schedule,dayshours,NOISent,Approved,Received,PriorPermit,ExpirationDate,Location,Fire Prevention Districts,Police Districts,Supervisor Districts,Zip Codes,Neighborhoods (old)\n",
      "1514024,F & C Catering,Truck,0,,Assessors Block /Lot,,,,21MFF-00035,APPROVED,Cold Truck: Hot/Cold Sandwiches: Water: Soda: Juice: Snacks: Milk: Candies: Canned Food: Soups: Cup of Noodles: Fruit: Salad,,,0,0,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=21MFF-00035&ExportPDF=1&Filename=21MFF-00035_schedule.pdf,,,03/30/2021 12:00:00 AM,20210326,1,11/15/2021 12:00:00 AM,,,,,,\n",
      "1514023,C & F Catering,Truck,0,,Assessors Block /Lot,,,,21MFF-00035,EXPIRED,Cold Truck: Hot/Cold Sandwiches: Water: Soda: Juice: Snacks: Milk: Candies: Canned Food: Soups: Cup of Noodles: Fruit: Salad,,,0,0,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=21MFF-00035&ExportPDF=1&Filename=21MFF-00035_schedule.pdf,,,03/30/2021 12:00:00 AM,20210326,1,11/15/2021 12:00:00 AM,,,,,,\n"
    ]

    content
    |> Stream.map(& &1)
  end
end
