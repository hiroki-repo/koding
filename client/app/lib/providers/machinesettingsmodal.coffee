kd                   = require 'kd'
KDView               = kd.View
KDTabView            = kd.TabView
KDModalView          = kd.ModalView
KDTabPaneView        = kd.TabPaneView
KDCustomHTMLView     = kd.CustomHTMLView
KDTabHandleContainer = kd.TabHandleContainer

MachineSettingsSpecsView     = require './machinesettingsspecsview'
MachineSettingsGuidesView    = require './machinesettingsguidesview'
MachineSettingsGeneralView   = require './machinesettingsgeneralview'
MachineSettingsDomainsView   = require './machinesettingsdomainsview'
MachineSettingsAdvancedView  = require './machinesettingsadvancedview'
MachineSettingsDiskUsageView = require './machinesettingsdiskusageview'
MachineSettingsVMSharingView = require './machinesettingsvmsharingview'

PANE_CONFIG = [
  { title: 'General',       viewClass: MachineSettingsGeneralView   }
  { title: 'Specs',         viewClass: MachineSettingsSpecsView     }
  { title: 'Disk Usage',    viewClass: MachineSettingsDiskUsageView }
  { title: 'Domains',       viewClass: MachineSettingsDomainsView   }
  { title: 'VM Sharing',    viewClass: MachineSettingsVMSharingView }
  { title: 'Advanced',      viewClass: MachineSettingsAdvancedView  }
  { title: 'Common guides', viewClass: MachineSettingsGuidesView    }
]


module.exports = class MachineSettingsModal extends KDModalView

  constructor: (options = {}, data) ->

    options.cssClass = 'machine-settings-modal AppModal'
    options.title    = 'VM Settings'
    options.width    = 805
    options.height   = 400

    super options, data

    @panesByTitle = {}

    @createTabView()
    @createPanes()
    @tweakStyling_()

    @tabView.showPaneByIndex 0


  createTabView: ->

    tabHandleContainer = new KDTabHandleContainer cssClass: 'AppModal-nav'

    @addSubView tabHandleContainer

    @addSubView @tabView   = new KDTabView
      hideHandleCloseIcons : yes
      maxHandleWidth       : 190
      tabHandleContainer   : tabHandleContainer

    tabHandleContainer.unsetClass 'kdtabhandlecontainer'


  createPanes: ->

    for item in PANE_CONFIG when item.title and item.viewClass

      subView = new item.viewClass item.viewOptions, @getData()
      subView.once 'ModalDestroyRequested', @bound 'destroy'

      @tabView.addPane pane = new KDTabPaneView
        name     : item.title
        cssClass : 'AppModal-content'
        view     : subView

      @panesByTitle[item.title] = pane


  # MachineSettingsModal has same UI with AccountSettingsModal.
  # However to reuse ASM styling I needed to add/remove some classes.
  # We can consider this method later.
  tweakStyling_: ->

    for key, pane of @panesByTitle
      handle = pane.getHandle()
      handle.setClass   'AppModal-navItem' # styling
      handle.unsetClass 'kdtabhandle'      # styling
