# eve energy: Smart Plug & Power Meter

import digi
import digi.on as on
import digi.util as util
from digi.digilite.matter import Controller

matter_device = Controller()

@on.control
def do_control(pv, mount):
    power = util.get(pv, "control.power.intent")
    try:
        if power == 'on':
            matter_device.cluster('onoff').on(endpoints=1)
        else:
            matter_device.cluster('onoff').off(endpoints=1)
    except Exception as e:
        digi.logger.info(e)

def report():
    model = digi.rc.view()
    power = util.get(model, "control.power.intent")
    consumption = matter_device.cluster(319486977).read_by_id(319422474, endpoints=1)[0]["value"]
    watt = 0 if power != "on" or not consumption else round(consumption, 1)
    digi.model.patch({
        "obs": {
            "watt": watt
        }
    })
    digi.pool.load(
        [{
            "power": power,
            "watt": watt,
        }]
    )

loader = util.Loader(load_fn=report)

@on.meta
def do_meta(meta):    
    matter_device.pair(meta.get("matter_code", ""))
    
    i = meta.get("report_interval", -1)
    if i < 0:
        digi.logger.info("Stop loader")
        loader.stop()
    else:
        loader.start()    


if __name__ == '__main__':
    digi.run()
