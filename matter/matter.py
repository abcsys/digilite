#!/usr/bin/env python3

from chip import ChipDeviceCtrl
import chip.clusters as Clusters
from chip.ChipStack import *
import chip.FabricAdmin
import chip.CertificateAuthority
import chip.native as Native
from chip.utils import CommissioningBuildingBlocks
from chip.setup_payload import SetupPayload
import atexit
import asyncio
import time
from rich.pretty import pprint

class Controller:
  def __init__(
    self,
    persistentStoragePath='/tmp/repl-storage.json',
    installDefaultLogHandler=True,
    bluetoothAdapter=None,
    paaTrustStorePath='/src/paa-root-certs'
  ):
    Native.Init()
    self.stack = None
    self.ca_manager = None
    self.ca_lst = []
    
    def shutdown():
      if self.ca_manager:
        self.ca_manager.Shutdown()
      if self.stack:
        self.stack.Shutdown()
    
    atexit.register(shutdown)

    self.stack = ChipStack(
      persistentStoragePath=persistentStoragePath,
      installDefaultLogHandler=installDefaultLogHandler,
      bluetoothAdapter=bluetoothAdapter,
      enableServerInteractions=False
    )

    self.ca_manager = chip.CertificateAuthority.CertificateAuthorityManager(self.stack, self.stack.GetStorageManager())

    self.ca_manager.LoadAuthoritiesFromStorage()

    if len(self.ca_manager.activeCaList) == 0:
      ca = self.ca_manager.NewCertificateAuthority()
      ca.NewFabricAdmin(vendorId=0xFFF1, fabricId=1)
    elif len(self.ca_manager.activeCaList[0].adminList) == 0:
      self.ca_manager.activeCaList[0].NewFabricAdmin(vendorId=0xFFF1, fabricId=1)

    self.ca_list = self.ca_manager.activeCaList

    self.device_controller = self.ca_list[0].adminList[0].NewController(
      nodeId=1,
      paaTrustStorePath=paaTrustStorePath,
      useTestCommissioner=True
    )
    self.device_node = 1
  def connect(self, code):
    self.device_controller.CommissionWithCode(setupPayload=code, nodeid=self.device_node)
  
  def write(self, attributes):
    return asyncio.run(self.device_controller.WriteAttribute(
      nodeid=self.device_node,
      attributes=attributes
    ))
  def read(self, attributes):
    return asyncio.run(self.device_controller.ReadAttribute(
      nodeid=self.device_node,
      attributes=attributes,
      returnClusterObject=True,
      fabricFiltered=True,
      reportInterval=None,
      keepSubscriptions=True
    ))
  def subscribe(self, attributes, min_interval, max_interval):
    return asyncio.run(self.device_controller.ReadAttribute(
      nodeid=self.device_node,
      attributes=attributes,
      returnClusterObject=True,
      fabricFiltered=True,
      reportInterval=(min_interval, max_interval),
      keepSubscriptions=True,
    ))
  def invoke(self, payload):
    return asyncio.run(self.device_controller.SendCommand(nodeid=self.device_node, endpoint=1, payload=payload))
  def nearby_nodes(self):
    return self.device_controller.DiscoverCommissionableNodes()
