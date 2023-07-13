resource "null_resource" "ping_round_robin" {
  count = var.vm_count
  provisioner "local-exec" {
    command = <<EOF
      vm_ip_list=($(az vm list -d --query "[].{PublicIPs:publicIps}" -o tsv))
      index=${count.index}
      vm_count=${var.vm_count}

      next_index=$(((index + 1) % vm_count))
      
      echo "Pinging VM ${count.index} (${vm_ip_list[index]}) from VM ${next_index} (${vm_ip_list[next_index]})" >> ping_results.txt
      ssh adminuser@${vm_ip_list[next_index]} "ping -c 1 ${vm_ip_list[index]}" >> ping_results.txt
    EOF
      i=0
      echo "Pinging VM ${i} (${vm_ip_list[0]}) from VM ${next_index} (${vm_ip_list[next_index]})" >> ping_results.txt
      ssh adminuser@${vm_ip_list[next_index]} "ping -c 1 ${vm_ip_list[0]}" >> ping_results.txt
      
    interpreter = ["/bin/bash", "-c"]
  }
}

output "ping_results" {
  value = file("ping_results.txt")
}
