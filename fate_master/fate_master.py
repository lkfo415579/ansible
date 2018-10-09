# -*- coding: utf8 -*-
import requests
import logging
import argparse
import codecs
import os
import time

logging.basicConfig(level=logging.DEBUG,
                    format="%(asctime)s[%(process)d] - %(name)s - %(message)s",
                    filename='logs/fate_logs'
                    )
logger = logging.getLogger('NMTSERVER')


def reboot(port, server_data):
    f = codecs.open('tmp_host', 'wa')
    f.write("[nmt_server]\n")
    f.write(server_data + "\n")
    f.close()
    os.system('ansible-playbook refresh_decoder.yml --extra-vars "target_volume=' + port + '" -i tmp_host')
    print "Rebooting[port:%s] ... [%s]" % (port, server_data)
    logger.info("Rebooting[port:%s] ... [%s]" % (port, server_data))
    print "Sleep 10s"
    time.sleep(10)
    return


def check_slaves(url, port, server_data):
    target_url = "http://" + url + ":" + port + "/translate"
    headers = {'Content-Type': 'application/x-www-form-urlencoded', 'apikey': '37447ebe06e5af07b6f8e8e168714e39'}
    try:
        r = requests.post(target_url, data={'text': 'testing', 'detoken': 'true', 'nbest': '1'}, headers=headers, timeout=10)
    except:
        # server is down.
        logger.info("500|%s|%s" % (target_url, "Server is down."))
        reboot(port, server_data)
        return
    # normal 500 external error
    if r.status_code == 500:
        logger.info("500|%s|%s" % (target_url, r.text))
        # reboot(port, server_data)
        return
    # other responses
    logger.info("%s|%s|%s" % (target_url, r.status_code, r.text))


if __name__ == "__main__":
    logger.info("Starting Main Program...")
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--duration', type=float, required=False,
                        help="Duration between each checking, unit in min. default=1", default=1)
    parser.add_argument('--config', type=str, required=True,
                        help="nmtserver locations file")
    parser.add_argument('-i', '--inventory', type=str, required=True,
                        help="inventory path")
    args = parser.parse_args()
    servers = codecs.open(args.config, 'r', encoding='utf8').readlines()
    servers = [server.strip() for server in servers]
    if args.inventory[-1] == '/':
        args.inventory = args.inventory[:-1]
    # get ports
    server_entity = []
    for line in servers:
        # commented
        if len(line) == 0 or line[0] == '#':
            continue
        print "Readling server config ....:", line
        # 192.168.50.6 ansible_ssh_user=newtranx ansible_ssh_private_key_file=id_rsa ansible_ssh_port=6500 server_id=6
        serverdata = line.split()
        server = serverdata[0]
        last_id = serverdata[-1].split("=")[1]
        tmp_ports = codecs.open(args.inventory + "/" + last_id + ".volumes", 'r', encoding='utf8').readlines()
        server_entity.extend([(server, port.strip(), line) for port in tmp_ports if port.strip() != ""])
    # ports = [server.split(":")[1] for server in servers]
    print "Writting Servers entities . . . ."
    f = codecs.open("entities", "w", "utf-8")
    for entity in server_entity:
        f.write(str(entity) + "\n")
    f.close()
    print "Starting fate master checker"
    print "Duration of checking : %f mins" % args.duration
    # print "Server Entity:", server_entity
    # (server, port)
    while(True):
        logger.info("###Starting check all servers")
        for index, entity in enumerate(server_entity):
            check_slaves(entity[0], entity[1], entity[2])
        logger.info("###waiting for next move.")
        time.sleep(args.duration * 60)
