# eve door & window: wireless contact sensor

import digi
import digi.on as on
import digi.util as util
from digi.digilite.matter import Controller

matter_device = Controller()

def report():
    closed = matter_device.cluster('booleanstate').read('state-value', endpoints=1)[0]["value"]
    digi.model.patch({
        "obs": {
            "closed": closed
        }
    })
    digi.pool.load([{ "closed": closed }])

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
